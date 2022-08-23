/**
 *Submitted for verification at BscScan.com on 2022-08-23
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-16
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
        _previousOwner = address(0); // vulnerability fix
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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
    ) external returns (
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
    ) external payable returns (
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

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IBEP20 constant BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    IDEXRouter immutable router;

    address[] shareholders;
    mapping(address => uint256) shareholderIndexes;
    mapping(address => uint256) shareholderClaims;

    mapping(address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10**36;

    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 1 * (10**18);

    uint256 currentIndex;

    bool initialized;

    modifier initialization() { require(!initialized, 'non init'); _; initialized = true; }
    modifier onlyToken() {require(msg.sender == _token, 'unauth'); _; }

    constructor(address _router) {
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        _token = msg.sender;
    }

    receive() external payable {}

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
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
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = BUSD.balanceOf(address(this));
        uint256 swapBNB = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(BUSD);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: swapBNB}(0, path, address(this), block.timestamp);

        uint256 amount = BUSD.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
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

    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if (shares[shareholder].amount == 0) {
            return;
        }

        uint256 amount = getUnpaidEarnings(shareholder);

        if (amount > 0) {
            totalDistributed = totalDistributed.add(amount);
            BUSD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if (shares[shareholder].amount == 0) {
            return 0;
        }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if (shareholderTotalDividends <= shareholderTotalExcluded) {
            return 0;
        }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
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

contract RMC is IBEP20, Ownable {
    using SafeMath for uint256;

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event BuybackMultiplierActive(uint256 duration);
    event Error(string reason);

    address private constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address private constant ZERO = 0x0000000000000000000000000000000000000000;

    string private constant _name = 'Reward Miner Coin';
    string private constant _symbol = 'RMC';

    uint8 private constant _decimals = 18;

    uint256 private constant _totalSupply = 1000000000000000 * (10**_decimals);

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isTxLimitExempt;
    mapping(address => bool) isDividendExempt;
    mapping(address => bool) isFreezeExempt;
    mapping(address => uint256) public vestingDuration;
    mapping(address => uint256) public vestingBalance;

    mapping (address => bool) public isBlacklisted;

    uint256 public launchTimeStamp = type(uint128).max;
    uint256 public launchedAt;
    uint256 public lastBuyback;

    uint256 public _maxTxAmount = 5000000000000 * (10**18);

    uint256 public liquidityBuyFee = 200;
    uint256 public buybackBuyFee = 200;
    uint256 public reflectionBuyFee = 1400;
    uint256 public marketingBuyFee = 200;
    uint256 public totalBuyFee = 2000;

    uint256 public liquiditySellFee = 200;
    uint256 public buybackSellFee = 200;
    uint256 public reflectionSellFee = 1400;
    uint256 public marketingSellFee = 200;
    uint256 public totalSellFee = 2000;

    uint256 public liquiditySwapFee = (liquidityBuyFee + liquiditySellFee) / 2;
    uint256 public buybackSwapFee = (buybackBuyFee + buybackSellFee) / 2;
    uint256 public reflectionSwapFee = (reflectionBuyFee + reflectionSellFee) / 2;
    uint256 public marketingSwapFee = (marketingBuyFee + marketingSellFee) / 2;
    uint256 public totalSwapFee = (totalBuyFee + totalSellFee) / 2;

    uint256 public feeDenominator = 10000;

    uint256 public swapThreshold = 100000000000 * (10**18);
    uint256 public distributorGas = 750000;

    address public autoLiquidityReceiver;
    address payable public marketingFeeReceiver;
    address public pair;
    address public distributorAddress;
    
    IDEXRouter public router;
    DividendDistributor distributor;

    bool public feesOnNormalTransfers = false;
    bool public freeze_contract = false;
    bool public autoBuybackEnabled = false;
    bool public swapEnabled = false;

    bool inSwap;

    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor() {
        address dexRouter_ = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        router = IDEXRouter(dexRouter_);

        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = _totalSupply;

        distributor = new DividendDistributor(address(router));
        distributorAddress = address(distributor);

        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;

        isFreezeExempt[msg.sender] = true;
        isFreezeExempt[address(this)] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[address(this)] = true;

        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[msg.sender] = true;

        uint256 distributed;

        autoLiquidityReceiver = payable(msg.sender);
        marketingFeeReceiver = payable(msg.sender);

        approve(address(router), _totalSupply);

        _balances[owner()] = _totalSupply.sub(distributed);
        emit Transfer(address(0), owner(), _totalSupply.sub(distributed));
    }

    receive() external payable {}

    /*
     * Transaction Functions
     */
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][_msgSender()] != _totalSupply) {
            _allowances[sender][_msgSender()] = _allowances[sender][_msgSender()].sub(amount, 'Insufficient Allowance');
        }
        return _transferFrom(sender, recipient, amount);
    }
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(!isBlacklisted[recipient] && !isBlacklisted[sender], 'Address is blacklisted');
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], 'TX Limit Exceeded');
        require(!checkVesting(sender,amount));
        require(!freezeStatus(sender, recipient), "Contract frozen!");
        
        if(!launched() && recipient == pair){ require(_balances[sender] > 0); launch(); }

        if (inSwap) { return _basicTransfer(sender, recipient, amount); }

        if (shouldSwapBack()) swapBack();
        if (shouldAutoBuyback()) triggerBuyback();

        _balances[sender] = _balances[sender].sub(amount, 'Insufficient Balance');
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, amount, isSell(recipient)) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);

        if (!isDividendExempt[sender]) {
            try distributor.setShare(sender, _balances[sender]) {} catch Error(string memory reason) { emit Error(reason); }
        }

        if (!isDividendExempt[recipient]) {
            try distributor.setShare(recipient, _balances[recipient]) {} catch Error(string memory reason) { emit Error(reason); }
        }

        try distributor.process(distributorGas) {} catch Error(string memory reason) {
            emit Error(reason);
        }

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    function freezeStatus(address _sender, address _recipient) internal view returns (bool) {
        if(isFreezeExempt[_sender] || isFreezeExempt[_recipient]){return false; }
        return freeze_contract;
    }
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, 'Insufficient Balance');
        _balances[recipient] = _balances[recipient].add(amount);
        return true;
    }
    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        if (isFeeExempt[sender] || isFeeExempt[recipient] || !launched()) return false;

        if (sender == pair || recipient == pair) return true;

        return feesOnNormalTransfers;
    }
    function getTotalFee(bool _issell) public view returns (uint256) {
        if(launchedAt + 1 >= block.number){ return feeDenominator.sub(1); }
        if (_issell) {
            return totalSellFee;
        }
        else {
            return totalBuyFee;
        }
    }
    function takeFee(address _sender, uint256 _amount, bool _issell) internal returns (uint256) {
        uint256 feeAmount = _amount.mul(getTotalFee(_issell)).div(feeDenominator);
        
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(_sender, address(this), feeAmount);

        return _amount.sub(feeAmount);
    }
    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair && !inSwap && swapEnabled && _balances[address(this)] >= swapThreshold;
    }
    function swapBack() internal swapping {
        uint256 amountToLiquify = swapThreshold.mul(liquiditySwapFee).div(totalSwapFee).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;
        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountToSwap, 0, path, address(this), block.timestamp);

        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        uint256 totalBNBFee = totalSwapFee.sub(liquiditySwapFee.div(2));

        uint256 amountBNBLiquidity = amountBNB.mul(liquiditySwapFee).div(totalBNBFee).div(2);
        uint256 amountBNBReflection = amountBNB.mul(reflectionSwapFee).div(totalBNBFee);
        uint256 amountBNBMarketing = amountBNB.mul(marketingSwapFee).div(totalBNBFee);

        try distributor.deposit{value: amountBNBReflection}() {} catch {}
        payable(marketingFeeReceiver).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value: amountBNBLiquidity}(address(this), amountToLiquify, 0, 0, autoLiquidityReceiver, block.timestamp);
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }
    function shouldAutoBuyback() internal view returns (bool) {
        return
        msg.sender != pair &&
        !inSwap &&
        autoBuybackEnabled
        && address(this).balance >= 1 * (10**18)
        && lastBuyback + 90 days >= block.timestamp;
    }
    function triggerBuyback() internal swapping {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(this);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: address(this).balance}(0, path, DEAD, block.timestamp);
    }
    function withdrawStuckBNB() external onlyOwner {
        require(address(this).balance > 0, 'Cannot withdraw negative or zero');
        payable(owner()).transfer(address(this).balance);
    }
    function checkVesting(address _sender, uint256 _amount) internal view returns (bool) {
        if(launchTimeStamp + vestingDuration[_sender] > block.timestamp) {
            if(_amount > IBEP20(address(this)).balanceOf(_sender).sub(vestingBalance[_sender])) {
                return true;
            }
        }
        return false;
    }
    function isSell(address recipient) internal view returns (bool) {
        if (recipient == pair) return true;
        return false;
    }

    /*
     * Contract Settings
     */
    function addVesting(address _wallet, uint256 _balance, uint256 _duration) external onlyOwner {
        require(vestingBalance[_wallet] < 1, "Vesting information already entered");
        vestingDuration[_wallet] = _duration;
        vestingBalance[_wallet] = _balance;
    }
    function blacklistAddress(address _address, bool _value) external onlyOwner{
        isBlacklisted[_address] = _value;
    }    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }
    function setAutoBuybackSettings(bool _enabled) external onlyOwner {
        autoBuybackEnabled = _enabled;
    }
    function setTxLimit(uint256 amount) external onlyOwner {
        require(amount >= _totalSupply / 1000);
        _maxTxAmount = amount;
    }
    function setIsDividendExempt(address holder, bool exempt) external onlyOwner {
        require(holder != address(this));
        isDividendExempt[holder] = exempt;
        if (exempt) {
            distributor.setShare(holder, 0);
        } else {
            distributor.setShare(holder, _balances[holder]);
        }
    }
    function setFreezeExempt(address _wallet, bool _exempt) external onlyOwner {
        isFreezeExempt[_wallet] = _exempt;
    }
    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }
    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }
    function setFees(
        uint256 _liquiditybuyfee, uint256 _buybackbuyfee, uint256 _reflectionbuyfee, uint256 _marketingbuyfee,
        uint256 _liquiditysellfee, uint256 _buybacksellfee, uint256 _reflectionsellfee, uint256 _marketingsellfee, uint256 _feeDenominator
    ) external onlyOwner {
        liquidityBuyFee = _liquiditybuyfee;
        buybackBuyFee = _buybackbuyfee;
        reflectionBuyFee = _reflectionbuyfee;
        marketingBuyFee = _marketingbuyfee;
        totalBuyFee = _liquiditybuyfee.add(_buybackbuyfee).add(_reflectionbuyfee).add(_marketingbuyfee);

        liquiditySellFee = _liquiditysellfee;
        buybackSellFee = _buybacksellfee;
        reflectionSellFee = _reflectionsellfee;
        marketingSellFee = _marketingsellfee;
        totalSellFee = _liquiditysellfee.add(_buybacksellfee).add(_reflectionsellfee).add(_marketingsellfee);

        liquiditySwapFee = (liquidityBuyFee + liquiditySellFee) / 2;
        buybackSwapFee = (buybackBuyFee + buybackSellFee) / 2;
        reflectionSwapFee = (reflectionBuyFee + reflectionSellFee) / 2;
        marketingSwapFee = (marketingBuyFee + marketingSellFee) / 2;
        totalSwapFee = (totalBuyFee + totalSellFee) / 2;

        feeDenominator = _feeDenominator;
        uint256 effectiveTaxBuy = totalBuyFee.mul(100).div(feeDenominator);
        uint256 effectiveTaxSell = totalSellFee.mul(100).div(feeDenominator);
        require(effectiveTaxBuy <= 25 && effectiveTaxSell <= 25, "Taxes are set too high");
    }
    function launch() internal {
        lastBuyback = block.timestamp;
        launchTimeStamp = block.timestamp;
        launchedAt = block.number;
    }
    function setFeeReceivers(address _autoLiquidityReceiver, address payable _marketingFeeReceiver) external onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
    }
    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyOwner {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }
    function setDistributorSettings(uint256 gas) external onlyOwner {
        distributorGas = gas;
    }
    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }
    function freeze(bool _freeze) external onlyOwner {
        freeze_contract = _freeze;
    }

    /*
     * Contract Info
     */
    function totalSupply() external pure override returns (uint256) {
        return _totalSupply;
    }
    function decimals() external pure override returns (uint8) {
        return _decimals;
    }
    function symbol() external pure override returns (string memory) {
        return _symbol;
    }
    function name() external pure override returns (string memory) {
        return _name;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }
    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }
    function getVestingRemaining(address _wallet) public view returns (uint256) {
        return block.timestamp.add(launchTimeStamp).sub(vestingDuration[_wallet]);
    }
    function getVestingAmount(address _wallet) public view returns (uint256) {
        return vestingBalance[_wallet];
    }
}