/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

//SPDX-License-Identifier: MIT
    
pragma solidity ^0.8.0;

    abstract contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
    /**
     * BEP20 standard interface.
     */
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
        function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution,uint256 _minHoldReq) external;
        function setShare(address shareholder, uint256 amount) external;
        function deposit() external payable;
        function process(uint256 gas) external;        
        function claimDividendFor(address shareholder) external;
        function getShareholderInfo(address shareholder) external view returns (uint256, uint256, uint256, uint256);
        function getAccountInfo(address shareholder) external view returns (uint256, uint256, uint256, uint256);
        
    }

 contract Token is IBEP20 {
        
        address public owner;
        address BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        address DEAD = 0x000000000000000000000000000000000000dEaD;
        address public autoLiquidityReceiver;
        address public marketingFeeReceiver;
        address public pair;
        IDEXRouter public router;
        IDividendDistributor public distributor;

        string constant _name = "TOKEN";
        string constant _symbol = "TOKEN";
        uint8 constant _decimals = 9;
    
        uint256 constant _initialSupply = 180_000_000; // put supply amount here
        uint256 _totalSupply = _initialSupply * (10 ** _decimals); // total supply amount        
        uint256 maxTxPercent = 1;
        uint256 maxTxDivisor = 100;
        uint256 public _maxTxAmount = _totalSupply*(maxTxPercent)/(maxTxDivisor);

        mapping (address => uint256) _balances;
        mapping (address => mapping (address => uint256)) _allowances;        
        mapping (address => uint256) buycooldown;
        mapping (address => uint256) sellcooldown;
        mapping (address => bool) isFeeExempt;
        mapping (address => bool) isTxLimitExempt;
        mapping (address => bool) isDividendExempt;
        mapping (address => bool) bannedUsers;
        mapping (address => bool) authorizations;
        
        struct Icooldown{
            bool buycooldownEnabled;
            bool sellcooldownEnabled;
            uint256 _cooldown;
            uint256 cooldownLimit;}
        Icooldown public cooldownInfo = Icooldown({
            buycooldownEnabled: true,
            sellcooldownEnabled: true,
            _cooldown: 30 seconds,
            cooldownLimit: 60 seconds});
    

        uint256 liquidityFeeAccumulator;
    	
        struct IFees {
            uint256 liquidityFee;
            uint256 buybackFee;
            uint256 reflectionFee;
            uint256 marketingFee;
            uint256 totalFee;}
        IFees public BuyFees;
        IFees public SellFees;
        IFees public MaxFees = IFees({
            reflectionFee: 15,
            buybackFee: 5,
            liquidityFee: 5,
            marketingFee: 5,
            totalFee: MaxFees.reflectionFee+MaxFees.buybackFee+MaxFees.liquidityFee+MaxFees.marketingFee});

        uint256 feeDenominator = 100;
        uint256 public sellMultiplier = 1;
        uint256 public constant maxSellMultiplier = 3;
        uint256 marketingFees;
        
        bool public feeEnabled = true;
        bool public autoLiquifyEnabled = true;
        bool inSwap;
        bool autoClaimEnabled = true;
        bool swapEnabled = true;
        bool autoBuybackEnabled = false;
        uint256 autoBuybackCap;
        uint256 autoBuybackAccumulator;
        uint256 autoBuybackAmount;
        uint256 autoBuybackBlockPeriod;
        uint256 autoBuybackBlockLast;
        uint256 public launchedAt;
        uint256 distributorGas = 500000;
        uint256 swapThreshold = _totalSupply / 4000; // 0.025%
        uint256 lastSwap;
        uint256 swapInterval = 30 seconds;
        modifier swapping() { inSwap = true; _; inSwap = false; }
        modifier onlyOwner() {
            require(isOwner(msg.sender), "!OWNER"); _;
        }
        modifier authorized() {
            require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
        }

        constructor (address payable m) {
            owner = msg.sender;
            authorizations[owner] = true;
            router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
            pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
            _allowances[address(this)][address(router)] = type(uint256).max;
    
            isFeeExempt[address(this)] = true;
            isFeeExempt[msg.sender] = true;
            isTxLimitExempt[msg.sender] = true;
            isTxLimitExempt[address(this)] = true;
    
            autoLiquidityReceiver = m;
            marketingFeeReceiver = m;
            setBuyFees(3,1,9,1);
            setSellFees(3,1,9,1);
            _balances[msg.sender] = _totalSupply;
            emit Transfer(address(0), msg.sender, _totalSupply);
        }
        
        function start(address addr) public authorized{            
            distributor = IDividendDistributor(addr);
            isDividendExempt[pair] = true;
            isDividendExempt[address(this)] = true;
            isDividendExempt[DEAD] = true;
        }

        receive() external payable { }
    
        function totalSupply() external view override returns (uint256) { return _totalSupply; }
        function decimals() external pure override returns (uint8) { return _decimals; }
        function symbol() external pure override returns (string memory) { return _symbol; }
        function name() external pure override returns (string memory) { return _name; }        
        function getOwner() external view override returns (address) { return owner; }
        function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
        function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    
        function approve(address spender, uint256 amount) public override returns (bool) {
            _allowances[msg.sender][spender] = amount;
            emit Approval(msg.sender, spender, amount);
            return true;
        }
    
        function approveMax(address sender, address spender, uint256 amount) private {
            _allowances[sender][spender] = amount;
            emit Approval(sender, spender, amount);
        }
    
        function transfer(address recipient, uint256 amount) external override returns (bool) {
            return _transferFrom(msg.sender, recipient, amount);
        }
    
        function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
            if (_allowances[sender][msg.sender] != type(uint256).max) {
                _allowances[sender][msg.sender] -= amount;
            }
    
            return _transferFrom(sender, recipient, amount);
        }
    
        function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
            require(bannedUsers[sender] == false, "Sender is banned");
            require(bannedUsers[recipient] == false, "Recipient is banned");
            if(inSwap){ return _basicTransfer(sender, recipient, amount); }
    
            checkLaunched(sender);
            checkTxLimit(sender, amount);
            if(cooldownInfo.buycooldownEnabled){
                if (sender == pair && recipient != address(router) && !isFeeExempt[recipient]) {
                    require(buycooldown[recipient] < block.timestamp);
                    buycooldown[recipient] = block.timestamp + cooldownInfo._cooldown;
                }  
            }

            if(cooldownInfo.sellcooldownEnabled){
                if (sender != pair && !isFeeExempt[sender]){
                    require(sellcooldown[sender] < block.timestamp);
                    sellcooldown[sender] = block.timestamp + cooldownInfo._cooldown;   
                }
            }
            if(shouldSwapBack()){ swapBack(); }
            if(shouldAutoBuyback()){ triggerAutoBuyback(); }
    
            if(!launched() && recipient == pair && isAuthorized(sender)){ require(_balances[sender] > 0); launch(); }
    
            _balances[sender] = _balances[sender] - amount;
    
            uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, recipient, amount) : amount;
            _balances[recipient] = _balances[recipient] + amountReceived;
    
            if(!isDividendExempt[sender]){ try distributor.setShare(sender, _balances[sender]) {} catch {} }
            if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, _balances[recipient]) {} catch {} }
    
            if(autoClaimEnabled){
                try distributor.process(distributorGas) {} catch {}
            }
    
            emit Transfer(sender, recipient, amountReceived);
            return true;
        }
    
        function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
            _balances[sender] = _balances[sender] - amount;
            _balances[recipient] = _balances[recipient] + amount;
            emit Transfer(sender, recipient, amount);
            return true;
        }
        
        function setSellMultiplier(uint256 SM) external authorized {
            require(SM <= maxSellMultiplier);
            sellMultiplier = SM;
        }

        function checkLaunched(address sender) internal view {
            require(launched() || isAuthorized(sender), "Pre-Launch Protection");
        }
    
        function checkTxLimit(address sender, uint256 amount) internal view {
            require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
        }
    
        function shouldTakeFee(address sender) internal view returns (bool) {
            return feeEnabled && !isFeeExempt[sender];
        }
    
        function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
            if(isFeeExempt[sender] || isFeeExempt[receiver]){
                return amount;
            }
            uint256 totalFee;
            if(sender == pair){
                totalFee = BuyFees.totalFee;
            } else {
                totalFee = SellFees.totalFee * sellMultiplier;
            }

            uint256 feeAmount = amount * totalFee / feeDenominator;
    
            _balances[address(this)] = _balances[address(this)] + feeAmount;
            emit Transfer(sender, address(this), feeAmount);
    
            if(receiver == pair && autoLiquifyEnabled){
                liquidityFeeAccumulator = liquidityFeeAccumulator + (feeAmount * (BuyFees.liquidityFee+SellFees.liquidityFee) / ((BuyFees.totalFee+SellFees.totalFee) + (BuyFees.liquidityFee+SellFees.liquidityFee)));
            }
    
            return amount - feeAmount;
        }
    
        function shouldSwapBack() internal view returns (bool) {
            return msg.sender != pair
            && !inSwap
            && swapEnabled
            && block.timestamp >= lastSwap + swapInterval
            && _balances[address(this)] >= swapThreshold;
        }
    
        function swapBack() internal swapping {
            lastSwap = block.timestamp;
            if(liquidityFeeAccumulator >= swapThreshold && autoLiquifyEnabled){
                liquidityFeeAccumulator = liquidityFeeAccumulator - swapThreshold;
                uint256 amountToLiquify = swapThreshold / 2;
    
                address[] memory path = new address[](2);
                path[0] = address(this);
                path[1] = WBNB;
    
                uint256 balanceBefore = address(this).balance;
    
                router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                    amountToLiquify,
                    0,
                    path,
                    address(this),
                    block.timestamp
                );
    
                uint256 amountBNB = address(this).balance - (balanceBefore);
    
                router.addLiquidityETH{value: amountBNB}(
                    address(this),
                    amountToLiquify,
                    0,
                    0,
                    autoLiquidityReceiver,
                    block.timestamp
                );
                
                emit AutoLiquify(amountBNB, amountToLiquify);
            }else{
                uint256 amountToSwap = swapThreshold;
    
                address[] memory path = new address[](2);
                path[0] = address(this);
                path[1] = WBNB;
    
                uint256 balanceBefore = address(this).balance;
    
                router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                    amountToSwap,
                    0,
                    path,
                    address(this),
                    block.timestamp
                );
    
                uint256 amountBNB = address(this).balance - (balanceBefore);
    
                uint256 amountBNBReflection = amountBNB * (BuyFees.reflectionFee+SellFees.reflectionFee) / (BuyFees.totalFee+SellFees.totalFee);
                uint256 amountBNBMarketing = amountBNB * (BuyFees.marketingFee+SellFees.marketingFee) / (BuyFees.totalFee+SellFees.totalFee);
    
                try distributor.deposit{value: amountBNBReflection}() {} catch {}
    
                (bool success, ) = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
                if(success){ marketingFees = marketingFees + amountBNBMarketing; }

    
                emit SwapBack(amountToSwap, amountBNB);
            }
        }
    
        function shouldAutoBuyback() internal view returns (bool) {
            return msg.sender != pair
            && !inSwap
            && autoBuybackEnabled
            && autoBuybackBlockLast + autoBuybackBlockPeriod <= block.number
            && address(this).balance >= autoBuybackAmount;
        }
    
        function buybackWEI(uint256 amount) external authorized {
            _buyback(amount);
        }
    
        function buybackBNB(uint256 amount) external authorized {
            _buyback(amount * (10 ** 18));
        }
    
        function _buyback(uint256 amount) internal {
            buyTokens(amount, DEAD);
            emit Buyback(amount);
        }
    
        function triggerAutoBuyback() internal {
            buyTokens(autoBuybackAmount, DEAD);
            autoBuybackBlockLast = block.number;
            autoBuybackAccumulator = autoBuybackAccumulator + autoBuybackAmount;
            if(autoBuybackAccumulator > autoBuybackCap){ autoBuybackEnabled = false; }
        }
    
        function buyTokens(uint256 amount, address to) internal swapping {
            address[] memory path = new address[](2);
            path[0] = WBNB;
            path[1] = address(this);
    
            router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
                0,
                path,
                to,
                block.timestamp
            );
        }
    
        function setAutoBuybackSettings(bool _enabled, uint256 _cap, uint256 _amount, uint256 _period) external authorized {
            autoBuybackEnabled = _enabled;
            autoBuybackCap = _cap;
            autoBuybackAccumulator = 0;
            autoBuybackAmount = _amount;
            autoBuybackBlockPeriod = _period;
            autoBuybackBlockLast = block.number;
            emit AutoBuybackSettingsUpdated(_enabled, _cap, _amount, _period);
        }
    
        function launched() internal view returns (bool) {
            return launchedAt != 0;
        }
    
        function launch() internal {
            launchedAt = block.number;
            autoClaimEnabled = true;
            emit Launch();
        }
    
        function setTxLimit(uint256 percent, uint256 divisor) external authorized {
            require(percent >= 1 && divisor < 1000);
            uint256 amount = _totalSupply * (percent) / (divisor);
            _maxTxAmount = amount;
            emit TxLimitUpdated(amount);
        }
    
        function setIsDividendExempt(address holder, bool exempt) external authorized {
            require(holder != address(this) && holder != pair);
            isDividendExempt[holder] = exempt;
            if(exempt){
                distributor.setShare(holder, 0);
            }else{
                distributor.setShare(holder, _balances[holder]);
            }
            emit DividendExemptUpdated(holder, exempt);
        }
    
        function setIsFeeExempt(address holder, bool exempt) external authorized {
            isFeeExempt[holder] = exempt;
            emit FeeExemptUpdated(holder, exempt);
        }
        
        function setWalletBanStatus(address user, bool banned) external authorized {
            if (banned) {
                require(block.timestamp + 3650 days > block.timestamp, "User was put in a cage.");
                bannedUsers[user] = true;
            } else {
                delete bannedUsers[user];
            }
            emit WalletBanStatusUpdated(user, banned);
        }
    
        function setIsTxLimitExempt(address holder, bool exempt) external authorized {
            isTxLimitExempt[holder] = exempt;
            emit TxLimitExemptUpdated(holder, exempt);
        }
        
        function setBuyFees(uint256 _liquidityFee,uint256 _buybackFee,uint256 _reflectionFee,uint256 _marketingFee) public authorized {
            require(_liquidityFee <= MaxFees.liquidityFee && _reflectionFee <= MaxFees.reflectionFee && _marketingFee <= MaxFees.marketingFee && _buybackFee <= MaxFees.buybackFee);
            BuyFees = IFees({
                liquidityFee:  _liquidityFee,
                buybackFee:    _buybackFee,
                reflectionFee: _reflectionFee,
                marketingFee:  _marketingFee,
                totalFee:  _liquidityFee+_buybackFee+_reflectionFee+_marketingFee
            });
        }
        
        function FeesEnabled(bool _enabled) external authorized {
            feeEnabled = _enabled;
            emit areFeesEnabled(_enabled);
        }

        function setSellFees(uint256 _liquidityFee,uint256 _buybackFee,uint256 _reflectionFee,uint256 _marketingFee) public authorized {
            require(_liquidityFee <= MaxFees.liquidityFee && _reflectionFee <= MaxFees.reflectionFee && _marketingFee <= MaxFees.marketingFee && _buybackFee <= MaxFees.buybackFee);
            SellFees = IFees({
                liquidityFee:  _liquidityFee,
                buybackFee:    _buybackFee,
                reflectionFee: _reflectionFee,
                marketingFee:  _marketingFee,
                totalFee:  _liquidityFee+_buybackFee+_reflectionFee+_marketingFee
            });
        }

        function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver) external authorized {
            autoLiquidityReceiver = _autoLiquidityReceiver;
            marketingFeeReceiver = _marketingFeeReceiver;
            emit FeeReceiversUpdated(_autoLiquidityReceiver, _marketingFeeReceiver);
        }
        
        function setCooldownEnabled(bool buy, bool sell, uint256 cooldown_) external onlyOwner() {
            require(cooldown_ <= cooldownInfo.cooldownLimit);
            cooldownInfo._cooldown = cooldown_;
            cooldownInfo.buycooldownEnabled = buy;
            cooldownInfo.sellcooldownEnabled = sell;
        }

        function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
            swapEnabled = _enabled;
            swapThreshold = _totalSupply * (_amount) / (10000);
            emit SwapBackSettingsUpdated(_enabled, _amount);
        }
    
        function setAutoLiquifyEnabled(bool _enabled) external authorized {
            autoLiquifyEnabled = _enabled;
            emit AutoLiquifyUpdated(_enabled);
        }
        
        function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution, uint256 _minHoldReq) external authorized {
            distributor.setDistributionCriteria(_minPeriod, _minDistribution, _minHoldReq);
        }
    
        function setDistributorSettings(uint256 gas, bool _autoClaim) external authorized {
            require(gas <= 1000000);
            distributorGas = gas;
            autoClaimEnabled = _autoClaim;
            emit DistributorSettingsUpdated(gas, _autoClaim);
        }
    
        function getAccumulatedFees() external view returns (uint256) {
            return marketingFees;
        }
    
        function getAutoBuybackSettings() external view returns (bool,uint256,uint256,uint256,uint256,uint256) {
            return (
                autoBuybackEnabled,
                autoBuybackCap,
                autoBuybackAccumulator,
                autoBuybackAmount,
                autoBuybackBlockPeriod,
                autoBuybackBlockLast
            );
        }
        
        function getAutoLiquifySettings() external view returns (bool,uint256) {
            return (
                autoLiquifyEnabled,
                liquidityFeeAccumulator
            );
        }
    
        function getSwapBackSettings() external view returns (bool,uint256) {
            return (
                swapEnabled,
                swapThreshold
            );
        }
        
        function getShareholderInfo(address shareholder) external view returns (uint256, uint256, uint256, uint256) {
            return distributor.getShareholderInfo(shareholder);
        }

        function getAccountInfo(address shareholder) external view returns (uint256, uint256, uint256, uint256) {
            return distributor.getAccountInfo(shareholder);
        }

        function claimDividendFor() public {
           distributor.claimDividendFor(msg.sender);
        }
    
        function authorize(address adr) public onlyOwner {
            authorizations[adr] = true;
            emit Authorized(adr);
        }
    
        function unauthorize(address adr) public onlyOwner {
            authorizations[adr] = false;
            emit Unauthorized(adr);
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
        event Authorized(address adr);
        event Unauthorized(address adr);
        event Launch();
        event AutoLiquify(uint256 amountBNB, uint256 amountToken);
        event SwapBack(uint256 amountToken, uint256 amountBNB);
        event Buyback(uint256 amountBNB);
        event AutoBuybackSettingsUpdated(bool enabled, uint256 cap, uint256 amount, uint256 period);
        event TxLimitUpdated(uint256 amount);
        event DividendExemptUpdated(address holder, bool exempt);
        event FeeExemptUpdated(address holder, bool exempt);
        event TxLimitExemptUpdated(address holder, bool exempt);
        event FeeReceiversUpdated(address autoLiquidityReceiver, address marketingFeeReceiver);
        event SwapBackSettingsUpdated(bool enabled, uint256 amount);
        event areFeesEnabled(bool _enabled);
        event AutoLiquifyUpdated(bool enabled);
        event DistributorSettingsUpdated(uint256 gas, bool autoClaim);
        event WalletBanStatusUpdated(address user, bool banned);
    }