/**
 *Submitted for verification at BscScan.com on 2022-06-07
*/

// Code written by MrGreenCrypto
// SPDX-License-Identifier: None

pragma solidity 0.8.14;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDEXRouter {
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

interface IDEXPair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
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

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

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

contract CheckMate is IBEP20 {
    string constant _name = "CheckMate";
    string constant _symbol = "CM";
    uint8 constant _decimals = 9;

    uint256 _totalSupply = 1_000_000_000 * (10**_decimals);

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    // Mapping of who is included in or excluded from fees, rewards or limits
    mapping(address => bool) public addressWithoutLimits;
    mapping(address => bool) public addressNotGettingRewards;

    mapping(address => uint256) _presaleContributions;
    mapping(uint256 => address) _contributorByID;
    uint256 public totalContributors;
    uint256 public totalContributionAmount;

    uint256 public tax = 6;
    uint256 private liq = 2;
    uint256 private marketing = 3;
    uint256 private diamond = 1;
    uint256 private initialJeetTax = 33;
    uint256 private timeUntilJeetTaxDecrease = 10 minutes;
    uint256 public jeetTax = 33;
    uint256 public taxDivisor = 100;
    uint256 public sellMultiplier = 2;
    uint256 private tokensFromJeetTax;
    uint256 public buys;
    uint256 public sells;
    uint256 private buysToStopEvent = 2;
    uint256 private buysUntilEvent = 10;
    uint256 private launchTime;

    bool public jeetTaxActive = true;
    bool public letTheJeetsOutEvent;

    IBEP20 public constant BUSD =
        IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address public constant CEO = 0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb;

    address public marketingWallet;
    address public diamondVaultAddress;
    address public pair;
    IDEXRouter public router;
    address private WETH;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    address[] shareholders;
    mapping(address => uint256) public shareholderIndexes;
    mapping(address => uint256) public lastClaim;
    mapping(address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalRewards;
    uint256 public totalDistributed;
    uint256 public rewardsPerShare;
    uint256 private veryLargeNumber = 10**36;
    uint256 private busdBalanceBefore;
    uint256 public rewardsToSendPerTx = 5;

    uint256 public minTokensForRewards = 500_000 * (10**_decimals);
    uint256 public minDistribution = 1 ether;
    uint256 private currentIndex;

    address[] public path = new address[](2);
    bool private isSwapping;

    modifier onlyOwner() {
        if (msg.sender != CEO) return;
        _;
    }

    modifier contractSelling() {
        isSwapping = true;
        _;
        isSwapping = false;
    }

    constructor(address _router, address _WETH) {
        router = IDEXRouter(_router);
        WETH = _WETH;
        path[0] = WETH;
        path[1] = address(BUSD);
        pair = IDEXFactory(IDEXRouter(router).factory()).createPair(
            WETH,
            address(this)
        );
        _allowances[address(this)][address(router)] = type(uint256).max;

        addressWithoutLimits[CEO] = true;
        addressWithoutLimits[address(this)] = true;

        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {return _totalSupply;
    }

    function decimals() external pure override returns (uint8) {return _decimals;}
    function symbol() external pure override returns (string memory) {return _symbol;}
    function name() external pure override returns (string memory) {return _name;}
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function allowance(address holder, address spender) external view override returns (uint256) {return _allowances[holder][spender];}
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function approveMax(address spender) external returns (bool) {return approve(spender, type(uint256).max);}
    function transfer(address recipient, uint256 amount) external override returns (bool) {return _transferFrom(msg.sender, recipient, amount);}

    function transferFrom(address sender, address recipient, uint256 amount ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            require(_allowances[sender][msg.sender] >= amount, "Insufficient Allowance");
            _allowances[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (
            isSwapping == true ||
            addressWithoutLimits[sender] == true ||
            addressWithoutLimits[recipient] == true
        ) return _lowGasTransfer(sender, recipient, amount);

        if (launchTime > block.timestamp) return true;

        if (buys >= buysUntilEvent && jeetTaxActive) letTheJeetsOut();

        if (conditionsToSwapAreMet(sender)) letTheContractSell();

        amount = jeetTaxActive ? takeJeetTax (sender, recipient, amount) : takeTax(sender, amount);
        return _basicTransfer(sender, recipient, amount);
    }

    function takeTax(address sender, uint256 amount) internal returns (uint256) {
        uint256 taxAmount = (amount * tax * sellMultiplier) / taxDivisor;
        if (sender == pair) taxAmount /= sellMultiplier;
        if (taxAmount > 0) _lowGasTransfer(sender, address(this), taxAmount);
        return amount - taxAmount;
    }

    function takeJeetTax(address sender, address recipient, uint256 amount) internal returns (uint256){
        uint256 taxAmount = (amount * tax * sellMultiplier) / taxDivisor;
        if (recipient == pair) sells++;
        if (sender == pair) buys++;
        if (letTheJeetsOutEvent && (sells > jeetTax || buys > buysToStopEvent)) stopLettingTheJeetsOut();
        if (sender == pair && letTheJeetsOutEvent) return amount;
        
        if (recipient == pair) {
            uint256 jeetTaxAmount = (amount * jeetTax) / 100;
            if (letTheJeetsOutEvent && sells <= jeetTax)
                jeetTaxAmount = (amount * (jeetTax - sells)) / 100;
            taxAmount += jeetTaxAmount;
            tokensFromJeetTax += jeetTaxAmount;
            if (taxAmount > 0)
                _lowGasTransfer(sender, address(this), taxAmount);
            return amount - taxAmount;
        }
        if (sender == pair) taxAmount /= sellMultiplier;
        if (taxAmount > 0) _lowGasTransfer(sender, address(this), taxAmount);
        
        return amount - taxAmount;
    }


    function letTheJeetsOut() internal {
        letTheJeetsOutEvent = true;
        sells = 0;
        buys = 0;
    }

    function stopLettingTheJeetsOut() internal {
        letTheJeetsOutEvent = false;
        sells = 0;
        buys = 0;
        if (jeetTaxActive && (block.timestamp - launchTime) / timeUntilJeetTaxDecrease >= initialJeetTax) jeetTaxActive = false;
        
        if (block.timestamp > launchTime + initialJeetTax * timeUntilJeetTaxDecrease ) {
            jeetTaxActive = false;
            return;
        }

        jeetTax = initialJeetTax - ((block.timestamp - launchTime) / timeUntilJeetTaxDecrease);
    }

    function jeetTaxRevival(
        uint256 _initialJeetTax,
        uint256 _hoursUntilJeetTaxDecrease
    ) external onlyOwner {
        timeUntilJeetTaxDecrease = _hoursUntilJeetTaxDecrease * 1 hours;
        initialJeetTax = _initialJeetTax;
        launchTime = block.timestamp;
        jeetTaxActive = true;
    }

    function conditionsToSwapAreMet(address sender)
        internal
        view
        returns (bool)
    {
        bool shouldSell = letTheJeetsOutEvent;
        if (!jeetTaxActive) shouldSell = true;
        return sender != pair && !isSwapping && shouldSell;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);

        if (!addressNotGettingRewards[sender])
            handleRewardsDistribution(sender);
        if (!addressNotGettingRewards[recipient])
            handleRewardsDistribution(recipient);

        return true;
    }

    function _lowGasTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function letTheContractSell() internal {
        uint256 tokensThatTheContractWillSell = (_balances[address(this)] * (tax - liq)) / tax;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokensThatTheContractWillSell,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 bnbToRewards = (address(this).balance * tokensFromJeetTax) /
            tokensThatTheContractWillSell;
        tokensFromJeetTax = 0;
        swapForBUSDRewards(bnbToRewards);

        _lowGasTransfer(address(this), pair, _balances[address(this)]);
        IDEXPair(pair).sync();

        payable(diamondVaultAddress).transfer((address(this).balance * diamond) / tax);
        payable(marketingWallet).transfer(address(this).balance);
    }

    function handleRewardsDistribution(address holder) internal {
        setShare(holder);
        process();
    }

    function makeContractSell() external onlyOwner {
        letTheContractSell();
    }

    function setWallets(address marketingAddress, address diamondAddress) external onlyOwner {
        marketingWallet = marketingAddress;
        diamondVaultAddress = diamondAddress;
    }

    function setLetTheJeetsOutEventParameters(
        uint256 _buysToStopEvent,
        uint256 _buysUntilEvent
    ) external onlyOwner {
        buysToStopEvent = _buysToStopEvent;
        buysUntilEvent = _buysUntilEvent;
    }

    function setRewardParameters(uint256 _rewardsToSendPerTx) external onlyOwner {
        require(_rewardsToSendPerTx < 20, "may cost too much gas");
        rewardsToSendPerTx = _rewardsToSendPerTx;
    }
    
    function rescueAnyToken(address token) external onlyOwner {
        IBEP20(token).transfer(
            msg.sender,
            IBEP20(token).balanceOf(address(this))
        );
    }

    function setTax(
        uint256 newTax,
        uint256 newTaxDivisor,
        uint256 newLiq,
        uint256 newMarketing,
        uint256 newDiamond,
        uint256 newSellMultiplier
    ) external onlyOwner {
        tax = newTax;
        taxDivisor = newTaxDivisor;
        liq = newLiq;
        marketing = newMarketing;
        diamond = newDiamond;
        sellMultiplier = newSellMultiplier;

        require(
            tax <= taxDivisor / 10 && sellMultiplier * tax >= 20,
            "Can't make a honeypot"
        );
    }

    function setAddressWithoutTax(address unTaxedAddress, bool status)
        external
        onlyOwner
    {
        addressWithoutLimits[unTaxedAddress] = status;
    }

    function launch() external payable onlyOwner {
        router.addLiquidityETH{value: msg.value}(
            address(this),
            _balances[address(this)],
            0,
            0,
            msg.sender,
            block.timestamp
        );
        jeetTaxActive = true;
        launchTime = block.timestamp;
    }

    function addBNBToRewardsManually() external payable {
        if (msg.value > 0) swapForBUSDRewards(msg.value);
    }

    function swapForBUSDRewards(uint256 bnbForRewards) internal {
        if (bnbForRewards == 0) return;
        busdBalanceBefore = BUSD.balanceOf(address(this));

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: bnbForRewards
        }(0, path, address(this), block.timestamp);

        uint256 newBusdBalance = BUSD.balanceOf(address(this));
        if (newBusdBalance <= busdBalanceBefore) return;

        uint256 amount = newBusdBalance - busdBalanceBefore;
        totalRewards += amount;
        rewardsPerShare =
            rewardsPerShare +
            ((veryLargeNumber * amount) / totalShares);
    }

    function setShare(address shareholder) internal {
        if (shares[shareholder].amount >= minTokensForRewards)
            distributeRewards(shareholder);

        if (
            shares[shareholder].amount == 0 &&
            _balances[shareholder] >= minTokensForRewards
        ) addShareholder(shareholder);

        if (
            shares[shareholder].amount >= minTokensForRewards &&
            _balances[shareholder] < minTokensForRewards
        ) {
            totalShares = totalShares - shares[shareholder].amount;
            shares[shareholder].amount = 0;
            removeShareholder(shareholder);
            return;
        }

        // already shareholder, just different balance
        if (_balances[shareholder] >= minTokensForRewards) {
            totalShares =
                totalShares -
                shares[shareholder].amount +
                _balances[shareholder];
            shares[shareholder].amount = _balances[shareholder]; ///
            shares[shareholder].totalExcluded = getTotalRewardsOf(
                shares[shareholder].amount
            );
        }
    }

    function process() internal {
        uint256 shareholderCount = shareholders.length;
        if (shareholderCount <= rewardsToSendPerTx) return;

        for (
            uint256 rewardsSent = 0;
            rewardsSent < rewardsToSendPerTx;
            rewardsSent++
        ) {
            if (currentIndex >= shareholderCount) currentIndex = 0;
            distributeRewards(shareholders[currentIndex]);
            currentIndex++;
        }
    }

    function claim(address claimer) external {
        if (getUnpaidEarnings(claimer) > 0) distributeRewards(claimer);
    }

    function distributeRewards(address shareholder) internal {
        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount < minDistribution) return;

        BUSD.transfer(shareholder, amount);
        totalDistributed = totalDistributed + amount;
        shares[shareholder].totalRealised =
            shares[shareholder].totalRealised +
            amount;
        shares[shareholder].totalExcluded = getTotalRewardsOf(
            shares[shareholder].amount
        );
    }

    function getUnpaidEarnings(address shareholder)
        public
        view
        returns (uint256)
    {
        uint256 shareholderTotalRewards = getTotalRewardsOf(
            shares[shareholder].amount
        );
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;
        if (shareholderTotalRewards <= shareholderTotalExcluded) return 0;
        return shareholderTotalRewards - shareholderTotalExcluded;
    }

    function getTotalRewardsOf(uint256 share) internal view returns (uint256) {
        return (share * rewardsPerShare) / veryLargeNumber;
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