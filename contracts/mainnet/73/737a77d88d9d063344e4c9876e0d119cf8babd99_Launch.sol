/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

// SPDX-License-Identifier: Unlicensed
//
// Launch Token is programmed to "self destruct" some time after it launches.
// When this happens, the contract will mint and sell enough tokens to buy back all the BNB currently in the Liquidity Pool.
// That BNB is then distributed to holders, all in one big payout.
//
// Tax: 10% Liquidity Fee
//
// Telegram: t.me/launchtoken

pragma solidity ^0.8.13;


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

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
}

contract DividendDistributor {
    
    using SafeMath for uint256;

    address immutable ownerContract;

    IDEXRouter immutable router;
    mapping (address => Share) public shares;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    uint256 public totalShares;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;
    address[] shareholders;
    uint256 public minDistribution = 0.002 * (10 ** 18); // 0.002 BNB worth
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 currentIndex;

    bool distributionInProgress = false;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    modifier onlyOwner {
        require(msg.sender == ownerContract); _;
    }

    receive() external payable {
        deposit();
     }

    constructor(address _router) {
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        ownerContract = msg.sender;
    }

    function setDistributionCriteria(uint256 _minDistribution) external onlyOwner {
        minDistribution = _minDistribution;
    }

    function setDistributionCriteria(uint256 _minTokens, uint8 _decimalPlaces) external onlyOwner {
        minDistribution = uint256(_minTokens * (10 ** _decimalPlaces));
    }

    function setShare(address shareholder, uint256 amount) external onlyOwner {
        if(shares[shareholder].amount > 0) {
            distributeDividend(shareholder);
        }
        if(amount > 0 && shares[shareholder].amount == 0) {
            addShareholder(shareholder);
        }
        else if(amount == 0 && shares[shareholder].amount > 0) {
            removeShareholder(shareholder);
        }
        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() public payable {
        require(totalShares > 0);
        uint256 amount = msg.value;
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }
    
    function process(uint256 gas) external onlyOwner {
        uint256 shareholderCount = shareholders.length;
        if (shareholderCount == 0) { return; }
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

    function shouldDistribute(address shareholder) internal view returns (bool) {
        return getUnpaidEarnings(shareholder) > minDistribution;
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function distributeDividend(address shareholder) internal {
        require(!distributionInProgress); // Prevent re-entrancy
        if (shares[shareholder].amount == 0) { return; }
        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount > 0) {
            distributionInProgress = true;
            if (payable(shareholder).send(amount)) {
                totalDistributed = totalDistributed.add(amount);
                shareholderClaims[shareholder] = block.timestamp;
                shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
                shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
            }
            distributionInProgress = false;
        }
    }

    function claimDividend(address claimAddress) external onlyOwner {
        distributeDividend(claimAddress);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if (shares[shareholder].amount == 0) { return 0; }
        if (getCumulativeDividends(shares[shareholder].amount) <= shares[shareholder].totalExcluded) { return 0; }
        return getCumulativeDividends(shares[shareholder].amount).sub(shares[shareholder].totalExcluded);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function clearStuckRewards(address _address, bool requireCleared) external onlyOwner {
        if (requireCleared) { require(shareholders.length == 0); }
        payable(_address).transfer(address(this).balance);
    }

}

interface IBEP20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function symbol() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Launch is IBEP20, Ownable {
    
    using SafeMath for uint256;

    string _name = "Launch Token";
    string _symbol = "LAUNCH";
    uint8 constant _decimals = 9;
    uint256 _totalSupply = 10 ** 6 * (10 ** _decimals); // 1,000,000 - 1M tokens
    uint256 constant _feeDenominator = 1000;
    uint256 public constant liquidityFee = 100; // 10% Liquidity fee
    uint256 public initialLP; // How much was contributed originally - subtracted from end payouts
    uint256 distributorGas = 600000;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;
    address immutable autoLiquidityReceiver = DEAD;
    address immutable deployer;
    uint256 swapThresholdDivisor = 1000; // 0.1%
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // Mainnet

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) isMaxHoldExempt;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isDividendExempt;
    mapping (address => bool) isTxLimitExempt;
    address immutable pancakeV2BNBPair;
    IDEXRouter immutable router;
    DividendDistributor immutable distributor;
    address public immutable distributorAddress;
    bool launched = false;
    bool public boomed = false;
    bool feesEnabled = true;
    bool inSwap;
    modifier swapInProgress {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier onlyDeployer {
        require(deployer == msg.sender, "Caller is not the deployer");
        _;
    }

    event ButtonPressed();

    function approveMax(address spender) external returns (bool) {
        return approve(spender, ~uint256(0));
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function name() external view override returns (string memory) { return _name; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function getOwner() external view override returns (address) { return deployer; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function totalSupply() external view override returns (uint256) { return _totalSupply; }

    receive() external payable { }

    constructor() Ownable() {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // Mainnet
        pancakeV2BNBPair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = ~uint256(0);
        distributor = new DividendDistributor(address(router));
        distributorAddress = address(distributor);
        isDividendExempt[DEAD] = true;
        isDividendExempt[ZERO] = true;
        isDividendExempt[pancakeV2BNBPair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[msg.sender] = true;
        isMaxHoldExempt[DEAD] = true;
        isMaxHoldExempt[pancakeV2BNBPair] = true;
        isMaxHoldExempt[address(this)] = true;
        isMaxHoldExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[msg.sender] = true;
        deployer = msg.sender;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function setMaxHoldExempt(address exAddress, bool set) external onlyDeployer {
        isMaxHoldExempt[exAddress] = set;
    }

    function setFeeExempt(address exAddress, bool set) external onlyDeployer {
        isFeeExempt[exAddress] = set;
    }

    function setDividendExempt(address exAddress, bool set) external onlyDeployer {
        isDividendExempt[exAddress] = set;
    }

    function setTxLimitExempt(address exAddress, bool set) external onlyDeployer {
        isTxLimitExempt[exAddress] = set;
    }

    function setSwapThresholdDivisor(uint256 swapThresholdDivisor_) external onlyDeployer {
        swapThresholdDivisor = swapThresholdDivisor_;
    }

    function setTokenDistributionCriteria(uint256 _minDistribution) external onlyDeployer {
        distributor.setDistributionCriteria(_minDistribution);
    }

    function setTokenDistributionCriteriaNoPeriod(uint256 _minTokens, uint8 _decimalPlaces) external onlyDeployer {
        distributor.setDistributionCriteria(_minTokens, _decimalPlaces);
    }

    function setDistributorGas(uint256 distributorGas_) external onlyDeployer {
        require(distributorGas_ <= 10000000);
        distributorGas = distributorGas_;
    }

    function setFeesEnabled(bool feesEnabled_) external onlyDeployer {
        feesEnabled = feesEnabled_;
    }

    function setInitialLP(uint256 initialLP_, uint256 decimals_) external onlyDeployer {
        initialLP = initialLP_ * (10 ** (18 - decimals_));
    }

    function setTokenName(string memory newName) external onlyDeployer {
        _name = newName;
    }

    function setTokenSymbol(string memory newSymbol) external onlyDeployer {
        _symbol = newSymbol;
    }

    function getSwapThreshold() internal view returns (uint256) {
        return _totalSupply.div(swapThresholdDivisor);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != ~uint256(0)){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(_balances[sender] > 0);
        require(checkMaxHold(recipient, amount), "Cannot hold more than 1 percent of supply");
        if (!launched && recipient == pancakeV2BNBPair) {
            require(sender == deployer, "Can't add to LP until launch");
            launched = true;
        }
        if (boomed) { 
            try distributor.claimDividend(msg.sender) {} catch {}
            try distributor.process(distributorGas) {} catch {}
        }
        if (inSwap || boomed) { return _basicTransfer(sender, recipient, amount); }
        else {  // Don't take fees or set shares after the boom, since it would significantly offset dividendsPerShare post-mint
            if (shouldSwapBack()) { swapBack(); }
            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
            uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, amount) : amount;
            _balances[recipient] = _balances[recipient].add(amountReceived);
            if(!isDividendExempt[sender]){ try distributor.setShare(sender, _balances[sender]) {} catch {} }
            if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, _balances[recipient]) {} catch {} }
            emit Transfer(sender, recipient, amountReceived);
            return true;
        }
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function checkMaxHold(address recipient, uint256 amount) internal view returns (bool) {
        if (feesEnabled) { amount = amount.sub(amount.mul(liquidityFee).div(_feeDenominator)); }
        uint256 maxHold = _totalSupply.div(100); // 1% max hold
        if (_balances[recipient].add(amount) <= maxHold || isMaxHoldExempt[recipient]) {
            return true;
        }
        return false;
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        if (isFeeExempt[sender] || isFeeExempt[recipient] || !feesEnabled) { return false; }
        if (sender == pancakeV2BNBPair || recipient == pancakeV2BNBPair) { return true; }
        return false;
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(liquidityFee).div(_feeDenominator);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }
    
    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pancakeV2BNBPair
        && !inSwap
        && _balances[address(this)] >= getSwapThreshold();
    }
    
    function swapBack() internal swapInProgress {
        uint256 amountToLiquify = _balances[address(this)].div(2);
        uint256 amountToSwap = _balances[address(this)].sub(amountToLiquify);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;
        router.swapExactTokensForETH(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amountBNBLiquidity = address(this).balance;
        if (amountToLiquify > 0) {
            router.addLiquidityETH{ value: amountBNBLiquidity }(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
        }
    }

    function claim() external {
        require(boomed, "The token has not been boomed yet");
        distributor.claimDividend(msg.sender);
        distributor.process(distributorGas);
    }

    function burn() external {
        require(boomed, "The token has not been boomed yet");
        uint256 amount = _balances[msg.sender];
        _balances[msg.sender] = 0;
        _totalSupply -= amount;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getActiveSupply() public view returns (uint256) {
        return getCirculatingSupply().sub(balanceOf(pancakeV2BNBPair));
    }

    // Debug function - Manual processing of reflections distributor
    function distributorProcess() external onlyDeployer {
        distributor.process(distributorGas);
    }

    // Debug function - Manual processing of reflections distributor with gas override
    function distributorProcessOverride(uint256 gasOverride) external onlyDeployer {
        distributor.process(gasOverride);
    }

    // Debug function - Distributes stuck BNB to distributor contract if needed
    function clearStuckBNB() external onlyDeployer {
        payable(distributorAddress).transfer(address(this).balance);
    }

    // Debug function - In case the contract wallet token needs to be swapped manually for any reason
    function swapBackDebug() external onlyDeployer {
        if(shouldSwapBack()){
            swapBack();
        }
    }

    // Debug function - In case the contract wallet token needs to be cleared manually for any reason
    function clearStuckToken() external onlyDeployer {
        uint256 thisBalance = _balances[address(this)];
        _balances[deployer] += thisBalance;
         _balances[address(this)] -= thisBalance;
        emit Transfer(address(this), deployer, thisBalance);
    }

    // Debug function - Anything leftover from rewards that was too small to be distributed as reflections is moved to decider to help pay for gas fees on the calls
    // If requireCleared == true, will revert if there are existing shareholders
    function clearStuckDistributorRewards(bool requireCleared) external onlyDeployer {
        distributor.clearStuckRewards(deployer, requireCleared);
    }

    // Debug function - Force a deposit to the distributor for the balance of the contract
    function distributorDeposit() external onlyDeployer {
        distributor.deposit{ value: address(this).balance }();
    }

    // Boom. Drains the liquidity pool to distribute BNB from the LP
    // No, this is not a "hidden mint", if TokenSniffer ends up saying that
    function redButton(bool areWeSure, uint256 multiplier) external onlyDeployer swapInProgress {
        require(areWeSure);
        require(initialLP > 0, "Initial LP must be set");
        require(_totalSupply < ~uint256(0).div(multiplier).add(_totalSupply), "Total supply must be less than uint256 max");
        boomed = true;
        feesEnabled = false;
        uint256 amountToAdd;
        amountToAdd = _totalSupply.mul(multiplier);
        _totalSupply = _totalSupply.add(amountToAdd);
        _balances[address(this)] = _balances[address(this)].add(amountToAdd);
        emit Transfer(address(0), address(this), amountToAdd);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;
        router.swapExactTokensForETH(
            _balances[address(this)],
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 devFeeAmount = address(this).balance.sub(initialLP).div(25);  // 4% dev fee
        devFeeAmount = devFeeAmount.add(initialLP);
        payable(deployer).transfer(devFeeAmount);
        distributor.deposit{ value: address(this).balance }();
        emit ButtonPressed();
    }

}