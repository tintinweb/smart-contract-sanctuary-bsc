/**
 *Submitted for verification at BscScan.com on 2022-06-14
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
    function createPair(address tokenA, address tokenB) external returns (address pair);
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
    ) external payable returns (uint256 amountToken,uint256 amountETH,uint256 liquidity);

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
    function sync() external;
}

contract JeetsAreFucked is IBEP20 {
    string constant _name = "JeetsAreFucked";
    string constant _symbol = "JAF";
    uint8 constant _decimals = 9;
    uint256 _totalSupply = 1_000_000_000 * (10**_decimals);

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public addressWithoutLimits;
    mapping(address => bool) public addressNotGettingRewards;
    mapping(address => uint256) private shareholderIndexes;
    mapping(address => uint256) public lastClaim;
    mapping(address => Share) public shares;

    uint256 public tax = 6;
    uint256 private liq = 2;
    uint256 private marketing = 3;
    uint256 private diamond = 1;
    uint256 private initialJeetTax = 33;
    uint256 public timeUntilJeetTaxDecrease = 10 minutes;
    uint256 public jeetTax = 33;
    uint256 private taxDivisor = 100;
    uint256 public sellMultiplier = 2;
    uint256 private tokensFromJeetTax;
    uint256 public buys;
    uint256 public sells;
    uint256 public buysToStopEvent = 2;
    uint256 public buysUntilEvent = 10;
    uint256 private launchTime;
    uint256 private totalShares;
    uint256 private totalRewards;
    uint256 private totalDistributed;
    uint256 private rewardsPerShare;
    uint256 private veryLargeNumber = 10**36;
    uint256 private busdBalanceBefore;
    uint256 private rewardsToSendPerTx = 5;
    uint256 private minTokensForRewards = 500_000 * (10**_decimals);
    uint256 private minDistribution = 1 ether;
    uint256 private lastRewardsTime;
    uint256 private timeBetweenRewards = 20 minutes;
    uint256 private currentIndex;

    bool private jeetTaxActive = true;
    bool public letTheJeetsOutEvent;
    bool private isSwapping;
    
    IDEXRouter public router;
    IBEP20 public constant BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address public constant CEO = 0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb;
    address public marketingWallet;
    address public diamondVaultAddress;
    address public pair;
    address public WETH;
    address[] public shareholders;
    address[] private pathForBuyingBUSD = new address[](2);
    address[] private pathForSellingJTD = new address[](2);

    event PartyStarted(uint256 startingTax);
    event PartyCrashed(uint256 howManySells, uint256 lowestSellTax);
    event PartyOver();
    event Buy(uint256 amount, uint256 buysLeft);
    event JeetSold(uint256 rewards);
    event PartyBuy(uint256 amount, uint256 buysLeft);
    event PartySell(uint256 newTax);
    event ContractSell(uint256 rewards);

    struct Share {uint256 amount;uint256 totalExcluded;uint256 totalRealised;}

    modifier onlyOwner() {if(msg.sender != CEO) return; _;}
    modifier contractSelling() {isSwapping = true; _; isSwapping = false;}

    constructor(address _router, address _WETH) {
        router = IDEXRouter(_router);
        WETH = _WETH;
        pathForBuyingBUSD[0] = WETH;
        pathForBuyingBUSD[1] = address(BUSD);
        pathForSellingJTD[1] = WETH;

        pair = IDEXFactory(IDEXRouter(router).factory()).createPair(WETH, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        addressWithoutLimits[CEO] = true;
        addressWithoutLimits[address(this)] = true;

        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    receive() external payable {}
    function name() public pure override returns (string memory) {return _name;}
    function totalSupply() public view override returns (uint256) {return _totalSupply;}
    function decimals() public pure override returns (uint8) {return _decimals;}
    function symbol() public pure override returns (string memory) {return _symbol;}
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function allowance(address holder, address spender) public view override returns (uint256) {return _allowances[holder][spender];}
    function approveMax(address spender) public returns (bool) {return approve(spender, type(uint256).max);}
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            require(_allowances[sender][msg.sender] >= amount, "Insufficient Allowance");
            _allowances[sender][msg.sender] -= amount;
        }
        
        return _transferFrom(sender, recipient, amount);
    }

    function rewardBalance(address holder) external view returns (uint256){
        return getUnpaidEarnings(holder);
    }

function claim(address claimer) external {
        if (getUnpaidEarnings(claimer) > 0) distributeRewards(claimer);
    }

    function sellForRewards() external onlyOwner {
        letTheContractSell();
    }

    function setWallets(address marketingAddress, address diamondAddress) external onlyOwner {
        marketingWallet = marketingAddress;
        diamondVaultAddress = diamondAddress;
    }

    function setLetTheJeetsOutEventParameters(uint256 _buysToStopEvent, uint256 _buysUntilEvent) external onlyOwner {
        buysToStopEvent = _buysToStopEvent;
        buysUntilEvent = _buysUntilEvent;
    }

    function setRewardParameters(uint256 _rewardsToSendPerTx, uint256 minutesBetweenRewards) external onlyOwner {
        require(_rewardsToSendPerTx < 20, "May cost too much gas");
        require(minutesBetweenRewards < 1440, "Can't let holders wait too long");
        rewardsToSendPerTx = _rewardsToSendPerTx;
        timeBetweenRewards = minutesBetweenRewards * 1 minutes;
    }

    function addBNBToRewardsManually() external payable {
        if (msg.value > 0) swapForBUSDRewards(msg.value);
    }
    
    function rescueAnyToken(address token) external onlyOwner {
        IBEP20(token).transfer(msg.sender, IBEP20(token).balanceOf(address(this)));
    }

    function rescueBnb() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function jeetTaxRevival(uint256 _initialJeetTax, uint256 _hoursUntilJeetTaxDecrease) external onlyOwner {
        timeUntilJeetTaxDecrease = _hoursUntilJeetTaxDecrease * 1 hours;
        initialJeetTax = _initialJeetTax;
        launchTime = block.timestamp;
        jeetTaxActive = true;
        require(initialJeetTax < 40, "Let the jeets out if they want");
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
        require(tax <= taxDivisor / 10 && sellMultiplier * tax >= 20, "Can't make a honeypot");
    }

    function setAddressWithoutTax(address unTaxedAddress, bool status) external onlyOwner {
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
        launchTime = block.timestamp;
        pathForSellingJTD[0] = address(this);
    }


    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
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

    function takeJeetTax(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 taxAmount = (amount * tax * sellMultiplier) / taxDivisor;
        if (recipient == pair) sells++;
        if (sender == pair) buys++;
        if (letTheJeetsOutEvent && (sells > jeetTax || buys > buysToStopEvent)) stopLettingTheJeetsOut();
        
        if (sender == pair && letTheJeetsOutEvent){
            emit PartyBuy(amount, buysToStopEvent - buys);
            return amount;    
        }

        if (recipient == pair) {
            uint256 jeetTaxAmount = (amount * jeetTax) / 100;
            if (letTheJeetsOutEvent && sells <= jeetTax) jeetTaxAmount = (amount * (jeetTax - sells)) / 100;
            taxAmount += jeetTaxAmount;
            tokensFromJeetTax += jeetTaxAmount;
            if (taxAmount > 0) _lowGasTransfer(sender, address(this), taxAmount);
            
            if(letTheJeetsOutEvent) emit PartySell((jeetTax - sells - 1) + tax * sellMultiplier);
            else emit JeetSold(jeetTaxAmount);
            
            return amount - taxAmount;
        }

        if (sender == pair) {
            taxAmount /= sellMultiplier;
            emit Buy(amount, buysUntilEvent - buys);
        }
        
        if (taxAmount > 0) _lowGasTransfer(sender, address(this), taxAmount);
        return amount - taxAmount;
    }

    function letTheJeetsOut() internal {
        letTheJeetsOutEvent = true;
        sells = 0;
        buys = 0;
        emit PartyStarted(tax * sellMultiplier + jeetTax);
    }

    function stopLettingTheJeetsOut() internal {
        letTheJeetsOutEvent = false;
        if(jeetTax - sells > 0) emit PartyCrashed(sells, (jeetTax-sells) + tax * sellMultiplier);
        else emit PartyOver();
        sells = 0;
        buys = 0;
        if (jeetTaxActive && (block.timestamp - launchTime) / timeUntilJeetTaxDecrease >= initialJeetTax) jeetTaxActive = false;
        
        if (block.timestamp > launchTime + initialJeetTax * timeUntilJeetTaxDecrease ) {
            jeetTaxActive = false;
            return;
        }

        jeetTax = initialJeetTax - ((block.timestamp - launchTime) / timeUntilJeetTaxDecrease);
    }

    function conditionsToSwapAreMet(address sender) internal view returns (bool) {
        bool shouldSell = letTheJeetsOutEvent;
        if (!jeetTaxActive) shouldSell = true;
        return sender != pair && !isSwapping && shouldSell;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);

        if (!addressNotGettingRewards[sender]) setShare(sender);
        if (!addressNotGettingRewards[recipient]) setShare(recipient);
        process();
        return true;
    }

    function _lowGasTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
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
            pathForSellingJTD,
            address(this),
            block.timestamp
        );

        uint256 bnbToRewards = (address(this).balance * tokensFromJeetTax) / tokensThatTheContractWillSell;
        tokensFromJeetTax = 0;
        swapForBUSDRewards(bnbToRewards);

        _lowGasTransfer(address(this), pair, _balances[address(this)]);
        IDEXPair(pair).sync();

        payable(diamondVaultAddress).transfer((address(this).balance * diamond) / tax);
        payable(marketingWallet).transfer(address(this).balance);
    }

    function swapForBUSDRewards(uint256 bnbForRewards) internal {
        if (bnbForRewards == 0) return;
        busdBalanceBefore = BUSD.balanceOf(address(this));

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: bnbForRewards}(
            0, pathForBuyingBUSD, address(this), block.timestamp
        );

        uint256 newBusdBalance = BUSD.balanceOf(address(this));
        if (newBusdBalance <= busdBalanceBefore) return;

        uint256 amount = newBusdBalance - busdBalanceBefore;
        totalRewards += amount;
        rewardsPerShare = rewardsPerShare + veryLargeNumber * amount / totalShares;
        emit ContractSell(amount);
    }

    function setShare(address shareholder) internal {
        if (shares[shareholder].amount >= minTokensForRewards) distributeRewards(shareholder);
        if (shares[shareholder].amount == 0 && _balances[shareholder] >= minTokensForRewards) addShareholder(shareholder);

        if (shares[shareholder].amount >= minTokensForRewards && _balances[shareholder] < minTokensForRewards) {
            totalShares = totalShares - shares[shareholder].amount;
            shares[shareholder].amount = 0;
            removeShareholder(shareholder);
            return;
        }

        if (_balances[shareholder] >= minTokensForRewards) {
            totalShares = totalShares - shares[shareholder].amount + _balances[shareholder];
            shares[shareholder].amount = _balances[shareholder];
            shares[shareholder].totalExcluded = getTotalRewardsOf(shares[shareholder].amount);
        }
    }

    function process() internal {
        uint256 shareholderCount = shareholders.length;
        if (shareholderCount <= rewardsToSendPerTx) return;
        if(currentIndex == 0) lastRewardsTime = block.timestamp;
        if(lastRewardsTime + timeBetweenRewards > block.timestamp) return;

        for (uint256 rewardsSent = 0; rewardsSent < rewardsToSendPerTx; rewardsSent++) {
            if (currentIndex >= shareholderCount) currentIndex = 0;
            distributeRewards(shareholders[currentIndex]);
            currentIndex++;
        }
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

    function getUnpaidEarnings(address shareholder) internal view returns (uint256) {
        uint256 shareholderTotalRewards = getTotalRewardsOf(shares[shareholder].amount);
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
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length - 1];
        shareholderIndexes[shareholders[shareholders.length - 1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}