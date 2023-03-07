/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

//SPDX-License-Identifier: MIT

//THIS TOKEN SERVES AS A LIQUIDITY SUPPLY FOR THE MARTIK ECO SYSTEM , 
//THOSE WHO BUY WMARTIK-Peg CAN EXCHANGE 1 FOR 1 FOR MARTIK AND THOSE WHO
// HAVE MARTIK CAN EXCHANGE 1 MARTIK FOR 1 WMARTIK-Peg THE EVOLUTION OF 
//THE ECO SYSTEM MARTIK IS HERE!

//ESTE TOKEN SERVE COMO ABASTECIMENTO DE LIQUIDEZ DO ECO SISTEMA MARTIK,
// QUEM COMPRAR Peg-WMARTIK PODE TROCAR 1 POR 1 POR MARTIK E QUEM TEM MARTIK 
//PODE TROCAR 1 MARTIK POR 1 Peg-WMARTIK A EVOLUÇÃO DO ECO SISTEMA MARTIK ESTA AQUI!

//Site:             https://martik.site/
//Telegram EUA:     https://t.me/martik_en
//Telegram  BR:     https://t.me/martik_pt
//Twitter:          https://twitter.com/martik_crypto

pragma solidity ^0.8.7;

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface BEP20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

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

interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IDividendDistributor {
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external;

    function setShare(address shareholder, uint256 amount) external;

    function deposit() external payable;

    function process(uint256 gas) external;
}

contract DividendDistributor is IDividendDistributor {
    address public _token;
    address public WBNB;
    address[] public shareholders;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    BEP20 public REWARD;
    IDEXRouter public router;

    mapping(address => uint256) public shareholderIndexes;
    mapping(address => uint256) public shareholderClaims;
    mapping(address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10**36;
    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 1 * (10**8);

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

    constructor(
        address _router,
        BEP20 reward,
        address token
    ) {
        REWARD = reward;
        router = IDEXRouter(_router);
        _token = token;
        WBNB = router.WETH();
    }

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
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
        totalShares = (totalShares - shares[shareholder].amount) + amount;
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(
            shares[shareholder].amount
        );
    }

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = REWARD.balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(REWARD);
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: msg.value
        }(0, path, address(this), block.timestamp);
        uint256 amount = REWARD.balanceOf(address(this)) - balanceBefore;
        totalDividends = totalDividends + amount;
        dividendsPerShare =
            dividendsPerShare +
            ((dividendsPerShareAccuracyFactor * amount) / totalShares);
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
            gasUsed = (gasUsed + gasLeft) - gasleft();
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
            totalDistributed = totalDistributed + amount;
            REWARD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised =
                shares[shareholder].totalRealised +
                amount;
            shares[shareholder].totalExcluded = getCumulativeDividends(
                shares[shareholder].amount
            );
        }
    }

    function claimDividend(address shareholder) external onlyToken {
        distributeDividend(shareholder);
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

    function setDividendTokenAddress(address newToken) external onlyToken {
        REWARD = BEP20(newToken);
    }
}

contract PegWMartik {
    DividendDistributor public distributor;
    IDEXRouter public router =
        IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    BEP20 WMTK = BEP20(0xA44145FB8962bc5f2458e94139e7e88C09Ef54A6);
    string constant _name = "Peg-WMartik";
    string constant _symbol = "PMTK";
    uint8 constant _decimals = 18;
    uint256 _totalSupply = 0;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) public _isExcludedFromFee;
    mapping(address => bool) public pair;
    mapping(address => bool) public isDividendExempt;

    uint256 public buyTax = 1000;
    uint256 public sellTax = 1000;

    //BUY FEES
    uint256 public liquidityFee = 0; 
    uint256 public marketingFee = 500; 
    uint256 public PoolFee = 0; 
    uint256 public reflectionFee = 500; 
    uint256 public burnFee = 0;

    //SELL FEES
    uint256 public sellLiquidityFee = 0; 
    uint256 public sellMarketingFee = 500; 
    uint256 public sellPoolFee = 0; 
    uint256 public sellReflectionFee = 500; 
    uint256 public sellBurnFee = 0; 

    uint256 public feeDenominator = 10000;
    uint256 distributorGas = 300000;
    uint256 txbnbGas = 50000;
    uint256 distributorBuyGas = 400000;
    uint256 LiquidifyGas = 500000;
    uint256 public swapThreshold = 10 * (10**_decimals);

    address public marketingFeeReceiver;
    address public StakePoolReceiver;
    address public buytokensReceiver;

    bool public swapEnabled = true;
    bool inSwap; 
    bool migrate;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    address WBNB = router.WETH();
    address private _owner;

    constructor() {
        _owner = msg.sender;
        _allowances[address(this)][address(router)] =
            100000000 *
            (10**50) *
            100;
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;

        marketingFeeReceiver = msg.sender;
        StakePoolReceiver = msg.sender;
        buytokensReceiver = msg.sender;

        _balances[msg.sender] = _totalSupply;
        address _pair = IDEXFactory(router.factory()).createPair(
            WBNB,
            address(this)
        );
        pair[_pair] = true;
        isDividendExempt[_pair] = true;
        isDividendExempt[address(this)] = true;
        distributor = new DividendDistributor(
            address(router),
            WMTK,
            address(this)
        );

        emit OwnershipTransferred(address(0), msg.sender);
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function name() external pure returns (string memory) {
        return _name;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender)
        external
        view
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function transfer(address recipient, uint256 amount)
        external
        returns (bool)
    {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        require(
            _allowances[sender][msg.sender] >= amount,
            "Insufficient Allowance"
        );
        _allowances[sender][msg.sender] =
            _allowances[sender][msg.sender] -
            amount;
        return _transferFrom(sender, recipient, amount);
    }

    function setPair(address _pair, bool io) public onlyOwner {
        pair[_pair] = io;
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setDividendExempt(address account, bool b) public onlyOwner {
        isDividendExempt[account] = b;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(amount != 0);
        require(amount <= _balances[account]);
        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - amount;
        emit Transfer(account, address(0), amount);
    }

    function toWrapped(uint256 amount) external {
        require(amount != 0);
        require(amount <= _balances[msg.sender]);
        _balances[msg.sender] = _balances[msg.sender] - amount;
        _totalSupply = _totalSupply - amount;
        WMTK.transfer(msg.sender, amount);
        emit Transfer(msg.sender, address(0), amount);
    }

    function towmartik(uint256 amount) external {
        require(migrate);
        uint256 Old = WMTK.balanceOf(address(this));
        WMTK.transferFrom(msg.sender, address(this), amount);
        uint256 NBal = WMTK.balanceOf(address(this));
        uint256 AM = NBal - Old;
        _balances[msg.sender] = _balances[msg.sender] + AM;
        _totalSupply = _totalSupply + AM;
        emit Transfer(address(0), msg.sender, AM);
    }
function setmigrate(bool io) external onlyOwner{
       migrate=io;
    }

    function _burnIN(address account, uint256 amount) internal {
        _totalSupply = _totalSupply - amount;
        emit Transfer(account, address(0), amount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return
            !pair[msg.sender] &&
            !inSwap &&
            swapEnabled &&
            _balances[address(this)] >= swapThreshold;
    }

    function setmarketingFeeReceivers(address _marketingFeeReceiver)
        external
        onlyOwner
    {
        marketingFeeReceiver = _marketingFeeReceiver;
    }

    function setStakePoolReceiver(address _autoStakePoolReceiver)
        external
        onlyOwner
    {
        StakePoolReceiver = _autoStakePoolReceiver;
    }

    function setbuytokensReceiver(address _buytokensReceiver)
        external
        onlyOwner
    {
        buytokensReceiver = _buytokensReceiver;
    }

    function setSwapBackSettings(bool _enabled) external onlyOwner {
        swapEnabled = _enabled;
    }

    function value(uint256 amount, uint256 percent)
        public
        view
        returns (uint256)
    {
        return (amount * percent) / feeDenominator;
    }

    function _isSell(bool a) internal view returns (uint256) {
        if (a) {
            return sellTax;
        } else {
            return buyTax;
        }
    }

    function BURNFEE(bool a) internal view returns (uint256) {
        if (a) {
            return sellBurnFee;
        } else {
            return burnFee;
        }
    }

    function MKTFEE(bool a) internal view returns (uint256) {
        if (a) {
            return sellMarketingFee;
        } else {
            return marketingFee;
        }
    }

    function LIQUIFYFEE(bool a) internal view returns (uint256) {
        if (a) {
            return sellLiquidityFee;
        } else {
            return liquidityFee;
        }
    }

    function STAKEPOOLFEE(bool a) internal view returns (uint256) {
        if (a) {
            return sellPoolFee;
        } else {
            return PoolFee;
        }
    }

    function REFPOOLFEE(bool a) internal view returns (uint256) {
        if (a) {
            return sellReflectionFee;
        } else {
            return reflectionFee;
        }
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            _basicTransfer(sender, recipient, amount);
            return true;
        } else {
            uint256 liquidifyFeeAmount = value(
                amount,
                LIQUIFYFEE(pair[recipient])
            );
            uint256 stkpoolFeeAmount = value(
                amount,
                STAKEPOOLFEE(pair[recipient])
            );
            uint256 marketingFeeAmount = value(amount, MKTFEE(pair[recipient]));
            uint256 refFeeAmount = value(amount, REFPOOLFEE(pair[recipient]));
            uint256 burnFeeAmount = value(amount, BURNFEE(pair[recipient]));

            uint256 FeeAmount = liquidifyFeeAmount +
                stkpoolFeeAmount +
                marketingFeeAmount +
                refFeeAmount;

            _txTransfer(sender, address(this), FeeAmount);

            swapThreshold = balanceOf(address(this));
            if (shouldSwapBack()) {
                swapBack(
                    marketingFeeAmount,
                    liquidifyFeeAmount,
                    stkpoolFeeAmount,
                    refFeeAmount
                );
            } else {
                _balances[address(this)] = _balances[address(this)] - FeeAmount;
                _txTransfer(address(this), buytokensReceiver, FeeAmount);

                swapThreshold = balanceOf(address(this));
            }
            _burnIN(sender, burnFeeAmount);
            uint256 feeAmount = value(amount, _isSell(pair[recipient]));
            uint256 amountWithFee = amount - feeAmount;

            _balances[sender] = _balances[sender] - amount;
            _balances[recipient] = _balances[recipient] + amountWithFee;

            if (!isDividendExempt[sender]) {
                try distributor.setShare(sender, balanceOf(sender)) {} catch {}
            }

            if (!isDividendExempt[recipient]) {
                try
                    distributor.setShare(recipient, balanceOf(recipient))
                {} catch {}
            }
            try distributor.process(distributorGas) {} catch {}
            emit Transfer(sender, recipient, amountWithFee);
            return true;
        }
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

    function _txTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
    }

    function getamount(uint256 amount, address[] memory path)
        internal
        view
        returns (uint256)
    {
        return router.getAmountsOut(amount, path)[1];
    }

    function swapBack(
        uint256 marketing,
        uint256 liquidity,
        uint256 stakePool,
        uint256 reflection
    ) internal swapping {
        uint256 a = marketing + liquidity + stakePool + reflection;
        if (a <= swapThreshold) {} else {
            a = swapThreshold;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        uint256 amountBNBLiquidity = liquidity > 0
            ? getamount(liquidity / 2, path)
            : 0;
        uint256 amountBNBMarketing = marketing > 0
            ? getamount(marketing, path)
            : 0;
        uint256 amountBNBStakePool = stakePool > 0
            ? getamount(stakePool, path)
            : 0;
        uint256 amountBNBReflection = reflection > 0
            ? getamount(reflection, path)
            : 0;

        uint256 amountToLiquidify = liquidity > 0 ? (liquidity / 2) : 0;

        uint256 amountToSwap = amountToLiquidify > 0
            ? a - amountToLiquidify
            : a;

        swapThreshold = balanceOf(address(this));

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        if (amountBNBMarketing > 0) {
            (bool success, ) = payable(marketingFeeReceiver).call{
                value: amountBNBMarketing,
                gas: txbnbGas
            }("");
            // payable(marketingFeeReceiver).transfer(amountBNBMarketing);
        }
        if (amountBNBStakePool > 0) {
            (bool success, ) = payable(StakePoolReceiver).call{
                value: amountBNBStakePool,
                gas: txbnbGas
            }("");
            //payable(StakePoolReceiver).transfer(amountBNBStakePool);
        }

        if (amountBNBReflection > 0) {
            try
                distributor.deposit{
                    value: amountBNBReflection,
                    gas: distributorBuyGas
                }()
            {} catch {}
        }

        if (amountToLiquidify > 0) {
            router.addLiquidityETH{
                value: amountToLiquidify <= address(this).balance
                    ? amountBNBLiquidity
                    : address(this).balance,
                gas: LiquidifyGas
            }(
                address(this),
                amountToLiquidify,
                0,
                0,
                address(this),
                block.timestamp
            );
        }
    }

    function setFees(
        uint256 _liquidityFee,
        uint256 _reflectionFee,
        uint256 _stakePoolFee,
        uint256 _burnFee,
        uint256 _marketingFee,
        uint256 _sellLiquidityFee,
        uint256 _sellReflectionFee,
        uint256 _sellStakePoolFee,
        uint256 _sellBurnFee,
        uint256 _sellMarketingFee
    ) external onlyOwner {
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
        reflectionFee = _reflectionFee;
        PoolFee = _stakePoolFee;
        burnFee = _burnFee;

        buyTax =
            _liquidityFee +
            _marketingFee +
            _stakePoolFee +
            _reflectionFee +
            _burnFee;

        sellLiquidityFee = _sellLiquidityFee;
        sellReflectionFee = _sellReflectionFee;
        sellPoolFee = _sellStakePoolFee;
        sellBurnFee = _sellBurnFee;
        sellMarketingFee = _sellMarketingFee;

        sellTax =
            _sellLiquidityFee +
            _sellReflectionFee +
            _sellStakePoolFee +
            _sellBurnFee +
            _sellMarketingFee;

    
    }

    function multiTransfer(
        address[] calldata addresses,
        uint256[] calldata tokens
    ) external {
        require(_isExcludedFromFee[msg.sender]);
        address from = msg.sender;

        require(
            addresses.length < 501,
            "GAS Error: max limit is 500 addresses"
        );
        require(
            addresses.length == tokens.length,
            "Mismatch between address and token count"
        );

        uint256 SCCC = 0;

        for (uint256 i = 0; i < addresses.length; i++) {
            SCCC = SCCC + tokens[i];
        }

        require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");

        for (uint256 i = 0; i < addresses.length; i++) {
            _basicTransfer(from, addresses[i], tokens[i]);
        }
    }

    function manualSend() external onlyOwner {
        payable(marketingFeeReceiver).transfer(address(this).balance);
        _basicTransfer(
            address(this),
            marketingFeeReceiver,
            balanceOf(address(this))
        );
    }

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external onlyOwner {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function claimDividend() external {
        distributor.claimDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder)
        public
        view
        returns (uint256)
    {
        return distributor.getUnpaidEarnings(shareholder);
    }

    function setDistributorSettings(uint256 gas) external onlyOwner {
        require(gas < 3000000);
        distributorGas = gas;
    }

    function setTXBNBgas(uint256 gas) external onlyOwner {
        require(gas < 100000);
        txbnbGas = gas;
    }

    function setDistribuitorBuyGas(uint256 gas) external onlyOwner {
        require(gas < 1000000);
        distributorBuyGas = gas;
    }

    function setLiquidifyGas(uint256 gas) external onlyOwner {
        require(gas < 1000000);
        LiquidifyGas = gas;
    }

    function setDividendToken(address _newContract) external onlyOwner {
        require(_newContract != address(0));
        distributor.setDividendTokenAddress(_newContract);
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}