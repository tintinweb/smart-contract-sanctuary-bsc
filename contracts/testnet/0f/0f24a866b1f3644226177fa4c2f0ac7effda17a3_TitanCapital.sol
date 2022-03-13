/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

/**
// SPDX-License-Identifier: MIT

Stealthlaunch 10th March
TG - https://t.me/MetisTitan
Twitter - https://twitter.com/TitanCapital_
Website - https://www.titancapital.xyz

Welcome to TitanCapital.

A community project that strives to provide a decentralized infrastructure, one that maximizes profits & capital efficiency for our members by farming & investing.

Built in Metis, we aim to grow alongside it. Our treasury will be deployed in ways which maximise returns for our investors, and encourage the Metis ecosystem to flourish and grow. We believe Metis has a large roll to play in crypto's future and are excited to be a part of it.

 .----------------.  .----------------.  .----------------.  .----------------.  .-----------------. .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------. 
| .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. |
| |  _________   | || |     _____    | || |  _________   | || |      __      | || | ____  _____  | || |     ______   | || |      __      | || |   ______     | || |     _____    | || |  _________   | || |      __      | || |   _____      | |
| | |  _   _  |  | || |    |_   _|   | || | |  _   _  |  | || |     /  \     | || ||_   \|_   _| | || |   .' ___  |  | || |     /  \     | || |  |_   __ \   | || |    |_   _|   | || | |  _   _  |  | || |     /  \     | || |  |_   _|     | |
| | |_/ | | \_|  | || |      | |     | || | |_/ | | \_|  | || |    / /\ \    | || |  |   \ | |   | || |  / .'   \_|  | || |    / /\ \    | || |    | |__) |  | || |      | |     | || | |_/ | | \_|  | || |    / /\ \    | || |    | |       | |
| |     | |      | || |      | |     | || |     | |      | || |   / ____ \   | || |  | |\ \| |   | || |  | |         | || |   / ____ \   | || |    |  ___/   | || |      | |     | || |     | |      | || |   / ____ \   | || |    | |   _   | |
| |    _| |_     | || |     _| |_    | || |    _| |_     | || | _/ /    \ \_ | || | _| |_\   |_  | || |  \ `.___.'\  | || | _/ /    \ \_ | || |   _| |_      | || |     _| |_    | || |    _| |_     | || | _/ /    \ \_ | || |   _| |__/ |  | |
| |   |_____|    | || |    |_____|   | || |   |_____|    | || ||____|  |____|| || ||_____|\____| | || |   `._____.'  | || ||____|  |____|| || |  |_____|     | || |    |_____|   | || |   |_____|    | || ||____|  |____|| || |  |________|  | |
| |              | || |              | || |              | || |              | || |              | || |              | || |              | || |              | || |              | || |              | || |              | || |              | |
| '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' |
 '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------' 

*/

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if(a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

}  

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
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
}

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setCurrentRewardAddress(address _CurrentrewardAddress) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;// excluded dividend
        uint256 totalRealised;
    }

    IERC20 public CurrentReward = IERC20(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);
    address WETH = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    IUniswapV2Router02 router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;// to be shown in UI
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 10 * (10 ** 18);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor (address _router) {
        router = _router != address(0)
        ? IUniswapV2Router02(_router)
        : IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        _token = msg.sender;
    }

    function setCurrentRewardAddress(address _CurrentrewardAddress) external override onlyToken {
        CurrentReward = IERC20(_CurrentrewardAddress);
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = CurrentReward.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = address(CurrentReward);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = CurrentReward.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
        && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            CurrentReward.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function claimDividend() external {
        distributeDividend(msg.sender);
    }
/*
returns the  unpaid earnings
*/
    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

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
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}

contract TitanCapital is Context, IERC20, Ownable {
    using SafeMath for uint256;

    uint256 public constant MASK = type(uint128).max;
    address public CurrentReward = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684; 
    address public WETH = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "TitanCapital";
    string constant _symbol = "TITAN";
    uint8 constant _decimals = 6;

    uint256 _totalSupply = 1_000_000_000_000_000 * (10 ** _decimals);
    uint256 public _maxTxAmount = _totalSupply.div(80); // 
    uint256 public _maxWallet = _totalSupply.div(40); // 

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isDividendExempt;
    mapping (address => bool) public _isFree;

    // Buy Tax
    uint256 liquidityFeeBuy = 500;
    uint256 vaultFeeBuy = 300;
    uint256 devFeeBuy = 150;
    uint256 reflectionFeeBuy = 0;
    uint256 marketingFeeBuy = 400;
    uint256 totalFeeBuy = 1350;

    // Sell Tax
    uint256 liquidityFeeSell = 600;
    uint256 vaultFeeSell = 400;
    uint256 devFeeSell = 150;
    uint256 reflectionFeeSell = 0;
    uint256 marketingFeeSell = 400;
    uint256 totalFeeSell = 1550;

    // Total Tax
    uint256 liquidityFeeTotal = 1100;
    uint256 vaultFeeTotal = 700;
    uint256 devFeeTotal = 300;
    uint256 reflectionFeeTotal = 0;
    uint256 marketingFeeTotal = 800;
    uint256 totalFee = 3000;

    uint256 feeDenominator = 20000;

    address public marketingFeeReceiver=0x3c00167F85630E2867bbe60D0023Ec5Af9dD2A42;
    address public vaultFeeReceiver=0x5FD04706aec14456DE4b521be2838315A8971D11;
    address public devFeeReceiver=0xB628ff181e3ddA0Cc98F138c1d67Bb49AFB659c6;

    IUniswapV2Router02 public router;
    address public pair;

    uint256 public launchedAt;
    uint256 public launchedAtTimestamp;

    DividendDistributor distributor;
    address public distributorAddress;

    uint256 distributorGas = 500000;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 5000; // 0.0025%
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () {
        address _router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
        router = IUniswapV2Router02(_router);
        pair = IUniswapV2Factory(router.factory()).createPair(WETH, address(this));
        _allowances[address(this)][address(router)] = _totalSupply;
        WETH = router.WETH();
        distributor = new DividendDistributor(_router);
        distributorAddress = address(distributor);

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        approve(_router, _totalSupply);
        approve(address(pair), _totalSupply);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    

    receive() external payable { }

    function totalSupply() public view override returns (uint256) { return _totalSupply; }
    function decimals() public pure returns (uint8) { return _decimals; }
    function symbol() public pure returns (string memory) { return _symbol; }
    function name() public pure returns (string memory) { return _name; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != _totalSupply){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }
         
        // Max  tx check
        address routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

        bool isSell=recipient== pair|| recipient == routerAddress;
        
        checkTxLimit(sender, amount);
        
        // Max wallet check excluding pair and router
        if (!isSell && !_isFree[recipient]){
            require((_balances[recipient] + amount) < _maxWallet, "Max wallet has been triggered");
        }
        
        // No swapping on buy and tx
        if (isSell) {
            if(shouldSwapBack()){ swapBack(); }
        }
        //        if(!launched() && recipient == pair){ require(_balances[sender] > 0); launch(); }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);

        if(!isDividendExempt[sender]){ try distributor.setShare(sender, _balances[sender]) {} catch {} }
        if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, _balances[recipient]) {} catch {} }

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
//        emit Transfer(sender, recipient, amount);
        return true;
    }



    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function getFee(bool selling) public view returns (uint256) {
        if(launchedAt + 1 >= block.number){ return totalFeeBuy; }
        if(selling){ return totalFeeSell; }
        return totalFeeBuy;
    }

    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(getFee(receiver == pair)).div(feeDenominator/2);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 amountToLiquify = contractTokenBalance.mul(liquidityFeeTotal).div(totalFee).div(2);
        uint256 amountToSwap = contractTokenBalance.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;
        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETH = address(this).balance.sub(balanceBefore);

        uint256 totalETHFee = totalFee.sub(liquidityFeeTotal.div(2));

        uint256 amountETHLiquidity = amountETH.mul(liquidityFeeTotal).div(totalETHFee).div(2);
        uint256 amountETHReflection = amountETH.mul(reflectionFeeTotal).div(totalETHFee);
        uint256 amountETHVault = amountETH.mul(vaultFeeTotal).div(totalETHFee);
        uint256 amountETHDev = amountETH.mul(devFeeTotal).div(totalETHFee);
        uint256 amountETHMarketing = amountETH.mul(marketingFeeTotal).div(totalETHFee);

        try distributor.deposit{value: amountETHReflection}() {} catch {}
        payable(marketingFeeReceiver).transfer(amountETHMarketing);
        payable(vaultFeeReceiver).transfer(amountETHVault);
        payable(devFeeReceiver).transfer(amountETHDev);
        addLiquidity(amountToLiquify, amountETHLiquidity);
        
    }

    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        if(tokenAmount > 0){
                router.addLiquidityETH{value: ETHAmount}(
                    address(this),
                    tokenAmount,
                    0,
                    0,
                    address(this),
                    block.timestamp
                );
                emit AutoLiquify(ETHAmount, tokenAmount);
            }
    }

    function buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = address(this);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            to,
            block.timestamp
        );
    }
    
    function Sweep() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }


    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() public onlyOwner {
        require(launchedAt == 0, "Already launched boi");
        launchedAt = block.number;
        launchedAtTimestamp = block.timestamp;
    }
    
    function setMaxWallet(uint256 amount) external onlyOwner {
        require(amount >= _totalSupply / 1000);
        _maxWallet = amount;
    }

    function setTxLimit(uint256 amount) external onlyOwner {
        require(amount >= _totalSupply / 1000);
        _maxTxAmount = amount;
    }

    function setIsDividendExempt(address holder, bool exempt) external onlyOwner {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, _balances[holder]);
        }
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }
    
    function setFree(address holder) public onlyOwner {
        _isFree[holder] = true;
    }
    
    function unSetFree(address holder) public onlyOwner {
        _isFree[holder] = false;
    }
    
    function checkFree(address holder) public view onlyOwner returns(bool){
        return _isFree[holder];
    }

    function setFeesBuy(uint256 _liquidityFee, uint256 _vaultFee, uint256 _reflectionFee, uint256 _marketingFee, uint256 _devFee) external onlyOwner {
        liquidityFeeBuy = _liquidityFee;
        vaultFeeBuy = _vaultFee;
        reflectionFeeBuy = _reflectionFee;
        devFeeBuy = _devFee;
        marketingFeeBuy = _marketingFee;
        totalFeeBuy = _liquidityFee.add(_reflectionFee).add(_marketingFee).add(_vaultFee).add(_devFee);

        liquidityFeeTotal = liquidityFeeBuy.add(liquidityFeeSell);
        vaultFeeTotal = vaultFeeBuy.add(vaultFeeSell);
        devFeeTotal = devFeeBuy.add(devFeeSell);
        reflectionFeeTotal = reflectionFeeBuy.add(reflectionFeeSell);
        marketingFeeTotal = marketingFeeBuy.add(marketingFeeSell);
        totalFee = totalFeeBuy.add(totalFeeSell);
        require(totalFee < feeDenominator/4);
    }

    function setFeesSell(uint256 _liquidityFee, uint256 _vaultFee, uint256 _reflectionFee, uint256 _marketingFee, uint256 _devFee) external onlyOwner {
        liquidityFeeSell = _liquidityFee;
        vaultFeeSell = _vaultFee;
        reflectionFeeSell = _reflectionFee;
        devFeeSell = _devFee;
        marketingFeeSell = _marketingFee;
        totalFeeSell = _liquidityFee.add(_reflectionFee).add(_marketingFee).add(_vaultFee).add(_devFee);

        liquidityFeeTotal = liquidityFeeBuy.add(liquidityFeeSell);
        vaultFeeTotal = vaultFeeBuy.add(vaultFeeSell);
        devFeeTotal = devFeeBuy.add(devFeeSell);
        reflectionFeeTotal = reflectionFeeBuy.add(reflectionFeeSell);
        marketingFeeTotal = marketingFeeBuy.add(marketingFeeSell);
        totalFee = totalFeeBuy.add(totalFeeSell);
        require(totalFee < feeDenominator/4);
    }

    function setFeeReceivers(address _devFeeReceiver, address _marketingFeeReceiver, address _vaultFeeReceiver) external onlyOwner {
        devFeeReceiver = _devFeeReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
        vaultFeeReceiver = _vaultFeeReceiver;
    }

    function setCurrentRewardAddress(address _CurrentRewardAddress) external onlyOwner {
        CurrentReward = _CurrentRewardAddress;
        distributor.setCurrentRewardAddress(_CurrentRewardAddress);
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyOwner {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 gas) external onlyOwner {
        require(gas < 750000);
        distributorGas = gas;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    event AutoLiquify(uint256 amountETH, uint256 amountBOG);
}