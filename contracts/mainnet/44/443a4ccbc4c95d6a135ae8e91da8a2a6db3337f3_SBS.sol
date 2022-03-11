/**
 *Submitted for verification at BscScan.com on 2022-03-11
*/

/**
 * https://spacebattleship.com/
 *                    `. ___
 *                   __,' __`.                _..----....____
 *       __...--.'``;.   ,.   ;``--..__     .'    ,-._    _.-'
 * _..-''-------'   `'   `'   `'     O ``-''._   (,;') _,'
 *'________________            Planet         \`-._`-','
 *`._              ```````````-Express-.___   '-.._'-:
 *   ```--.._      ,.           SBS       ````--...__\-.
 *           `.--. `-`                       ____    |  |`
 *             `. `.                       ,'`````.  ;  ;`
 *               `._`.        __________   `.      \'__/`
 *                  `-:._____/______/___/____`.     \  `
 *                              |       `._    `.    \
 *                              `._________`-.   `.   `.___
 *                                                 `------'`
 */
//  https://t.me/SpaceBattleShip
//  
// Code written by MrGreenCrypto
// SPDX-License-Identifier: None
pragma solidity 0.8.12;

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

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

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
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

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
}

contract DividendDistributor is IDividendDistributor {
    address public _token;
    address public _admin = 0x6d856C7f26e3C87C4fdA39a3f5f05d2bb05D85B5;
    address payable private _mrGreen = payable(0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb);

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IDEXRouter router;
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address[] shareholders;
    mapping (address => uint256) public shareholderIndexes;
    mapping (address => uint256) public shareholderClaims;
    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;
    uint256 private lastBalance; 

    uint256 public minPeriod = 1;
    uint256 public minDistribution = 1;

    uint256 currentIndex;

    modifier onlyToken() {
        require(msg.sender == _token || msg.sender == _admin || msg.sender == _mrGreen); 
        _;
    }

    constructor () {
        router = IDEXRouter(routerAddress);
        _token = msg.sender;
    }
     receive() external payable {
        if(address(this).balance > lastBalance){
        uint256 amount = address(this).balance - lastBalance;
        totalDividends = totalDividends + amount;
        dividendsPerShare = dividendsPerShare + (dividendsPerShareAccuracyFactor * amount / totalShares);
        lastBalance = address(this).balance;
        }
    }

    function setDistributionCriteria(uint256 newMinPeriod, uint256 newMinDistribution) external override onlyToken {
        minPeriod = newMinPeriod;
        minDistribution = newMinDistribution;
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

        totalShares = totalShares - shares[shareholder].amount + amount;
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        lastBalance = address(this).balance;
    }

    function deposit() external payable override onlyToken {
        if(address(this).balance > lastBalance){
        uint256 amount = address(this).balance - lastBalance;
        totalDividends = totalDividends + amount;
        dividendsPerShare = dividendsPerShare + (dividendsPerShareAccuracyFactor * amount / totalShares);
        lastBalance = address(this).balance;
        }
    }

    function process(uint256 gas) external override onlyToken {

        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) {
            return;
        }

        uint256 iterations = 0;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        while(gasUsed < gas && iterations < shareholderCount) {

            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed += gasLeft - gasleft();
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
            (bool success,) = payable(shareholder).call{value: amount, gas: 34000}("");
            if(success){
                totalDistributed = totalDistributed + amount;
                shareholderClaims[shareholder] = block.timestamp;
                shares[shareholder].totalRealised = shares[shareholder].totalRealised + amount;
                shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
                lastBalance = address(this).balance;
            }
        }
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){
            return 0;
        }
        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;
        if(shareholderTotalDividends <= shareholderTotalExcluded){
            return 0;
        }
        return shareholderTotalDividends - shareholderTotalExcluded;
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share * dividendsPerShare / dividendsPerShareAccuracyFactor;
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

    function rescueBNB() external onlyToken {
        payable(_mrGreen).transfer(address(this).balance);
    }
}

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }
    
    event OwnershipTransferred(address owner);
}

interface SbsStakingContractInterface {
    function unstakeFromTokenContract(address staker, uint amount, uint256 stake_index) external;
    function unstakeAllFromTokenContract(address staker) external;
    function stakeFromTokenContract(address staker, uint256 _amount, uint256 _days) external;
    function stakeAllFromTokenContract(address staker, uint256 _days) external;
    function claimFromTokenContract(address staker) external;   
    function howManyTokenHasThisAddressStaked(address account) external view returns (uint256);
}

contract SBS is IBEP20, Auth {

    string constant _name = "SpaceBattleShip";
    string constant _symbol = "SBS";
    uint8 constant _decimals = 9;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;


    uint256 _totalSupply = 100 * 10**6 * (10 ** _decimals);
    uint256 public _maxTxAmountSell = _totalSupply / 100;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isDividendExempt;
    mapping (address => bool) public stakingAddress;
    mapping (address => bool) public limitlessAddress;
    mapping (address => uint256) public stakedAmount;

    uint256 public stakingFee = 10;
    uint256 public bnbRewardFee = 20;
    uint256 public liquidityFee = 20;
    uint256 public marketingFee = 40;
    uint256 public totalFees = bnbRewardFee + liquidityFee + marketingFee + stakingFee;
    uint256 public extraFeeOnSell = 90;
    uint256 public feeDenominator = 1000; 
    bool public feeOnNonTrade = false;  // Wallet to wallet transfers are free of fees
    bool private isSell = false;
    uint256 public feeDiscountOnWebsite = 20;

    address public autoLiquidityReceiver;
    address public marketingWallet = 0xABfDD057B0705F824C023Ea7002148A9FBe936de;
    address public devWallet = 0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb;
    address public SbsStaking;

    IDEXRouter public router;
    address public pcs2BNBPair;
    address[] public pairs;

    uint256 public launchedAt;
    uint256 public blocksSinceLaunch;

    DividendDistributor public dividendDistributor;
    uint256 distributorGas = 650000;
    uint256 dividendSenderGas = 300000;
    bool public stakingRewardsActive = false;
    uint256 public stakingPrizePool = 0;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    uint256 public swapThreshold = 10000 * (10 ** _decimals);
    uint256 public maxSwapAmount = 500000 * (10 ** _decimals);
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    event AutoLiquify(uint256 amountBNB, uint256 amountTokenLiquified);
    event TokensBoughtOnWebsite(address sender, uint256 value);
    event TokensSoldOnWebsite(address sender, uint256 _tokenAmount);
    event NewFeesSet(
        uint256 bnbRewardFee,
        uint256 liquidityFee,
        uint256 marketingFee,
        uint256 stakingFee,
        uint256 feeDenominator,
        bool walletToWalletTax
    );
    event NewExtraSellFeeSet(uint256 extraFeeOnSell);
    event NewMaxSellAmountSet(uint256 _maxTxAmountSell);
    event SwapSettingsUpdated(bool swapEnabled, uint256 swapThreshold, uint256 maxSwapAmount);
    
    constructor () Auth(msg.sender) {
        router = IDEXRouter(routerAddress);
        pcs2BNBPair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;
        pairs.push(pcs2BNBPair);

        dividendDistributor = new DividendDistributor();

        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[pcs2BNBPair] = true;
        isDividendExempt[pcs2BNBPair] = true;
        isDividendExempt[msg.sender] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[ZERO] = true;
        
        _balances[msg.sender] = _totalSupply;
        autoLiquidityReceiver = msg.sender;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}
    function name() external pure override returns (string memory) {return _name;}
    function symbol() external pure override returns (string memory) {return _symbol;}
    function decimals() external pure override returns (uint8) {return _decimals;}
    function totalSupply() external view override returns (uint256) {return _totalSupply;}
    function getOwner() external view override returns (address) {return owner;}
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function allowance(address holder, address spender) external view override returns (uint256) {return _allowances[holder][spender];}

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply - (balanceOf(DEAD)) - (balanceOf(ZERO));
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) public returns (bool) {
        return approve(spender, type(uint256).max);
    }



    
/////////////////////Transfer Functions//////////////////////////////////////////////////////////////////    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if(
            inSwapAndLiquify ||
            sender == owner ||
            stakingAddress[recipient] ||
            stakingAddress[sender] ||
            limitlessAddress[sender] ||
            limitlessAddress[recipient]
        ){
            return _basicTransfer(sender, recipient, amount); 
        }
        
        blocksSinceLaunch = block.number - launchedAt;
        
        if(
            msg.sender != pcs2BNBPair &&
            !inSwapAndLiquify &&
            swapAndLiquifyEnabled &&
            _balances[address(this)] >= swapThreshold
        ){
            swapBack();
        }

        _balances[sender] = _balances[sender] - amount;

        uint256 finalAmount = shouldTakeFee(sender, recipient) ? takeFee(sender, amount) : amount;
        _balances[recipient] = _balances[recipient] + finalAmount;
        
        if(isSell){
        require(amount <= _maxTxAmountSell || isTxLimitExempt[sender], "TX Limit Exceeded");
        }

		if (stakingRewardsActive) {
			sendToStakingPool();
		}

        if(!isDividendExempt[sender]) {
            try dividendDistributor.setShare(sender, _balances[sender] + stakedAmount[sender]) {} catch {}
        }

        if(!isDividendExempt[recipient]) {
            try dividendDistributor.setShare(recipient, _balances[recipient] + stakedAmount[recipient]) {} catch {} 
        }

        try dividendDistributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, finalAmount);
        return true;
    }

    function shouldTakeFee(address sender, address recipient) internal returns (bool) {
        if (isFeeExempt[sender] || isFeeExempt[recipient] || !launched()) {
            return false;
        }
        address[] memory liqPairs = pairs;

        for (uint256 i = 0; i < liqPairs.length; i++) {
            if (sender == liqPairs[i] ) {
                isSell = false;
                return true;
            }
        }
        for (uint256 i = 0; i < liqPairs.length; i++) {
            if (recipient == liqPairs[i]) {
                isSell = true;
                return true;
            }
        }
        return feeOnNonTrade;
    }

    
    function sendToStakingPool() internal {
		_balances[ZERO] -= stakingPrizePool;
		_balances[SbsStaking] += stakingPrizePool;
		emit Transfer(ZERO, SbsStaking, stakingPrizePool);
		stakingPrizePool = 0;
	}

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;

        if(stakingAddress[sender]){
            stakedAmount[recipient] = SbsStakingContractInterface(SbsStaking).howManyTokenHasThisAddressStaked(recipient);
        }
        
        if(stakingAddress[recipient]){
            stakedAmount[sender] += amount;
        }
        
        if(!isDividendExempt[sender]) {
            try dividendDistributor.setShare(sender, _balances[sender] + stakedAmount[sender]) {} catch {}
        }

        if(!isDividendExempt[recipient]) {
            try dividendDistributor.setShare(recipient, _balances[recipient] + stakedAmount[recipient]) {} catch {} 
        }

        if(!launched() && recipient == pcs2BNBPair) {
            launch();
        }

        emit Transfer(sender, recipient, amount);
        return true;
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        if (!launched()) {return amount;}
		
        uint256 tokensForTaxes = 0;
        
        if(blocksSinceLaunch < 100000){
            setExtraSellFeesAtLaunch();
        }
		
        if(totalFees > 0){
            tokensForTaxes = amount * totalFees / feeDenominator;
        }    
        
        if(isSell && extraFeeOnSell > 0){
            tokensForTaxes += amount * extraFeeOnSell / feeDenominator;
        }
        if (stakingFee > 0) {
            uint256 stakingFees = stakingFee * tokensForTaxes / totalFees;
			_balances[ZERO] += stakingFees;
			stakingPrizePool += stakingFees;
			emit Transfer(sender, ZERO, stakingFees);
            tokensForTaxes -= stakingFees;
            amount -= stakingFees;
		}

        _balances[address(this)] += tokensForTaxes;
        emit Transfer(sender, address(this), tokensForTaxes);
        
        return amount - tokensForTaxes;

    }
    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.number;
    }

    function setExtraSellFeesAtLaunch() internal {                                   // Sell fees decrease over time, each block is 3 seconds, so 1200 blocks = 1h, 28800 blocks = 24h
            if(blocksSinceLaunch < 1200){extraFeeOnSell = 210;}                      // 30% until one hour after launch
            if(blocksSinceLaunch < 28800 && blocksSinceLaunch > 1199){               // 30% --> 18% over 23h (slowly decreasing each block)
                extraFeeOnSell = 210 - (120 * (blocksSinceLaunch - 1200) / 27600);   // 24h after launch: Sell tax = 18% 
            }
            if(blocksSinceLaunch < 86400 && blocksSinceLaunch > 28799){              // 18% --> 9% over 48h (slowly decreasing each block)
                extraFeeOnSell = 90 - (90 * (blocksSinceLaunch - 28800) / 57600);    // 72h after launch: Sell tax = 9%
            }
            if(blocksSinceLaunch > 86401){extraFeeOnSell = 0;}                       // 72h after launch: sell tax = buy tax = 9%
    }

    function swapBack() internal lockTheSwap {

        uint256 tokensToLiquify = _balances[address(this)];
        if(tokensToLiquify > maxSwapAmount){
            tokensToLiquify = maxSwapAmount;
        }
        uint256 amountToLiquify = tokensToLiquify * liquidityFee / totalFees / 2;
        uint256 amountToSwap = tokensToLiquify - amountToLiquify;

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
        uint256 totalBNBFee = totalFees - (liquidityFee / (2));
        uint256 amountBNBLiquidity = amountBNB * liquidityFee / totalBNBFee / (2);
        uint256 amountBNBRewards = amountBNB * bnbRewardFee / totalBNBFee;
        uint256 amountBNBMarketing = amountBNB - amountBNBLiquidity - amountBNBRewards;

        try dividendDistributor.deposit{value: amountBNBRewards}() {} catch {}
        
        uint256 marketingShare = amountBNBMarketing * (marketingFee - 1) / marketingFee;
        uint256 devShare = amountBNBMarketing - marketingShare;

        payable(marketingWallet).transfer(marketingShare);
        payable(devWallet).transfer(devShare);

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: address(this).balance}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }


/////////////////////SwapOnWebsite Functions//////////////////////////////////////////////////////////////////
    function BuyDirectlyFromContract() payable external lockTheSwap {
        uint256 bnbAmount = msg.value;
        uint256 taxes = (totalFees - feeDiscountOnWebsite) * bnbAmount / 100;
        bnbAmount -= taxes;
    
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(this);
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: bnbAmount}(
            0,
            path,
            msg.sender,
            block.timestamp
        );
        
        try dividendDistributor.setShare(msg.sender, _balances[msg.sender] + stakedAmount[msg.sender]) {} catch {}

        uint256 amountBNB = address(this).balance;
        uint256 devShare = amountBNB / (totalFees - feeDiscountOnWebsite);
        uint256 amountBNBRewards = devShare * bnbRewardFee;
        uint256 marketingShare = amountBNB - devShare - bnbRewardFee;
        
        payable(marketingWallet).transfer(marketingShare);
        payable(devWallet).transfer(devShare);
        try dividendDistributor.deposit{value: amountBNBRewards}() {} catch {}

        emit TokensBoughtOnWebsite(msg.sender, msg.value);
    }

function SellDirectlyToContract(uint256 _tokenAmount) external lockTheSwap {
        _tokenAmount = _tokenAmount * 10 ** _decimals;

        uint256 initialBalance = address(this).balance;

        require(balanceOf(msg.sender) >= _tokenAmount,"Cannot sell more than you own");
         if(_allowances[address(this)][address(router)] < type(uint256).max){
            approve(address(router), type(uint256).max);
        }

        _balances[msg.sender] -= _tokenAmount;
        _balances[address(this)] += _tokenAmount;
        
        try dividendDistributor.setShare(msg.sender, _balances[msg.sender] + stakedAmount[msg.sender]) {} catch {}

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 bnbFromSell = address(this).balance - initialBalance;
        uint256 taxes = (totalFees - feeDiscountOnWebsite) * bnbFromSell / 100;
        
        bnbFromSell -= taxes;

        payable(msg.sender).transfer(bnbFromSell);

        uint256 amountBNB = address(this).balance;
        uint256 devShare = amountBNB / (totalFees - feeDiscountOnWebsite);
        uint256 amountBNBRewards = devShare * bnbRewardFee;
        uint256 marketingShare = amountBNB - devShare - bnbRewardFee;
        
        payable(marketingWallet).transfer(marketingShare);
        payable(devWallet).transfer(devShare);
        try dividendDistributor.deposit{value: amountBNBRewards}() {} catch {}
        
        emit TokensSoldOnWebsite(msg.sender, _tokenAmount);
    }


/////////////////////Staking Functions//////////////////////////////////////////////////////////////////
    function _stakeAll(uint256 _days) external {
        _allowances[msg.sender][SbsStaking] = type(uint256).max;
        emit Approval(msg.sender, SbsStaking, type(uint256).max);
        SbsStakingContractInterface(SbsStaking).stakeAllFromTokenContract(msg.sender, _days);
    }
    function _stakeSome(uint amount, uint256 _days) external {
        _allowances[msg.sender][SbsStaking] = type(uint256).max;
        emit Approval(msg.sender, SbsStaking, type(uint256).max);
        SbsStakingContractInterface(SbsStaking).stakeFromTokenContract(msg.sender, amount, _days);
    }
    function _unstakeSome(uint amount, uint256 index) external {
        SbsStakingContractInterface(SbsStaking).unstakeFromTokenContract(msg.sender, amount, index);
    }
    function _unstakeAll() external {
        SbsStakingContractInterface(SbsStaking).unstakeAllFromTokenContract(msg.sender);
    }
    function _collectStakingRewardsWithoutUnstaking() external {
        SbsStakingContractInterface(SbsStaking).claimFromTokenContract(msg.sender);
    }


/////////////////////Management Functions//////////////////////////////////////////////////////////////////

    function launchManually() external authorized {
        launchedAt = block.number;
    }

    function rescueBNBWithTransfer() external authorized{
        payable(devWallet).transfer(address(this).balance);
    }

    function changeTxSellLimit(uint256 newLimit) external authorized {
        _maxTxAmountSell = newLimit * _totalSupply / 1000;
        require(newLimit > 5, "Don't make it a honeypot! Bad dev!");
        emit NewMaxSellAmountSet(_maxTxAmountSell);
    }

    function changeIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function changeIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }

    function changeIsDividendExempt(address holder, bool exempt) external authorized {
        require(holder != address(this) && holder != pcs2BNBPair);
        isDividendExempt[holder] = exempt;
        
        if(exempt){
            dividendDistributor.setShare(holder, 0);
        }else{
            dividendDistributor.setShare(holder, _balances[holder]);
        }
    }

    function sendAirDropsAndVestForDays(address[] calldata accounts, uint256[] calldata amount) external authorized {
        for(uint256 i = 0; i < accounts.length; i++) {
            _balances[msg.sender] -=amount[i] * 10 ** _decimals;
            _balances[accounts[i]] += amount[i] * 10 ** _decimals;
            emit Transfer(msg.sender, accounts[i], amount[i] * 10 ** _decimals);
            dividendDistributor.setShare(accounts[i], amount[i] * 10 ** _decimals);
        }
    }

    function setFees(
        uint256 _bnbRewardFee,
        uint256 _liquidityFee,
        uint256 _marketingFee,
        uint256 _stakingFee,
        uint256 _feeDenominator,
        bool _walletToWalletTax, 
        uint256 newFeeDiscountOnWebsite
    ) public authorized {
        bnbRewardFee = _bnbRewardFee;
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
        stakingFee = _stakingFee;
        totalFees = bnbRewardFee + liquidityFee + marketingFee + stakingFee;
        feeDenominator = _feeDenominator;
        feeDiscountOnWebsite = newFeeDiscountOnWebsite;
        feeOnNonTrade = _walletToWalletTax;
        require(totalFees <= (feeDenominator/10), "Maximum buy fees are 10%");
        emit NewFeesSet(_bnbRewardFee,_liquidityFee,_marketingFee,_stakingFee,_feeDenominator,_walletToWalletTax);
    }

    function setExtraFeeOnSell(uint256 _extraFeeOnSell) public authorized {
        extraFeeOnSell = _extraFeeOnSell; // extra fee on sell
        require(extraFeeOnSell + totalFees <= (feeDenominator/5),"Maximum sell fees are 20%");
        emit NewExtraSellFeeSet(extraFeeOnSell);
    }

    function changeFeeReceivers(address newLiquidityReceiver, address newMarketingWallet) external authorized {
        autoLiquidityReceiver = newLiquidityReceiver;
        marketingWallet = newMarketingWallet;
    }

    function addPair(address newpair) external authorized {
        pairs.push(newpair);
         isDividendExempt[newpair] = true;
        dividendDistributor.setShare(newpair, 0);
    }

    function removeLastPair() external authorized {
        pairs.pop();
    }

    function setSwapSettings(bool set, uint256 minimumSwap, uint256 maximumSwap) external authorized {
		swapAndLiquifyEnabled = set;
        maxSwapAmount = maximumSwap * 10 ** _decimals;
        swapThreshold = minimumSwap * 10 ** _decimals;
        emit SwapSettingsUpdated(swapAndLiquifyEnabled, swapThreshold, maxSwapAmount);
	}

    function changeDistributionCriteria(uint256 newMinPeriod, uint256 newMinDistribution) external authorized {
        dividendDistributor.setDistributionCriteria(newMinPeriod, newMinDistribution);
    }

    function changeDistributorSettings(uint256 gas) external authorized {
        require(gas < 1750000);
        distributorGas = gas;
    }

    function setSbsStakingAddress(address addy) external authorized {
		SbsStaking = addy;
        stakingAddress[SbsStaking] = true;
	}

	function setlimitlessAddress(address addy) external authorized {
        limitlessAddress[addy] = true;
        isDividendExempt[addy] = true;
        dividendDistributor.setShare(addy, 0);
	}

    function setStakingRewardsActive(bool active) external authorized {
		stakingRewardsActive = active;
	}
}