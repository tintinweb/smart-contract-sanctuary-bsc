/*
* TG: https://t.me/FullMoonPortal
*
* Author: @DaisyOfficialTG
*/
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Libraries.sol";

contract FullMoon is Ownable, IBEP20{
    
    uint256 private constant _totalSupply = 1_000_000_000*(10**9);
    uint8 private constant _decimals = 9;
    uint256 public liquidityUnlockSeconds;
    bool private _tradingEnabled;
    // Limits
    uint256 private _balanceLimitDivider=100;
    uint256 private _maxWalletSize=20000000*(10**9);
    uint256 private _maxBuyTx=10000000*(10**9);
    // Swap & Liquify
    uint8 public swapThreshold=35;
    bool public swapEnabled;
    bool private _inSwap;
    bool private _addingLP;
    bool private _removingLP;
    // Distributor
    uint256 public distributorGas=600000;
    DividendDistributor distributor;
    address public distributorAddress;
    // PancakeSwap
    IPancakeRouter02 private _pancakeRouter;
    address public pancakeRouterAddress=0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public pancakePairAddress;
    // Misc. Addresses
    address public burnWallet=0x000000000000000000000000000000000000dEaD;
    mapping(address=>uint256) private _balances;
    mapping(address=>mapping(address => uint256)) private _allowances;
    mapping(address=>bool)private _excludeFromFees;
    mapping(address=>bool)private _excludeFromRewards;
    mapping(address=>bool)private _marketMakers;
    Tracker private _tracker;
    struct Tracker {
        uint256 totalLPBNB;
        uint256 totalMarketingBNB;
        uint256 totalRewardBNB;
        uint256 totalRewardPayout;
    }
    Taxes private _taxes=Taxes(10,15,10,15,10,45,0,0,45);
    struct Taxes {
        uint8 maxBuyTax;
        uint8 maxSellTax;
        // Primary
        uint8 buyTax;
        uint8 sellTax;
        // Secondary
        uint8 liquidityTax;
        uint8 marketingTax;
        uint8 charityTax;
        uint8 lotteryTax;
        uint8 rewardsTax;
    }
    modifier LockTheSwap {
        _inSwap=true;
        _;
        _inSwap=false;
    }
    event OwnerLockLP(uint256 liquidityUnlockSeconds);
    event OwnerRemoveLP(uint16 LPPercent);
    event OwnerExtendLPLock(uint256 timeSeconds);
    event OwnerSwitchLotteryEnabled(bool enabled);
    event OwnerTriggerLottery(uint256 percentage);
    event OwnerBlacklist(address account,bool enabled);
    event OwnerUpdatePrimaryTaxes(uint8 buyTax,uint8 sellTax);
    event OwnerUpdateSecondaryTaxes(uint8 liquidityTax,uint8 marketingTax,uint8 rewardsTax);
    event OwnerEnableTrading(bool enabled);
    event OwnerSetSwapEnabled(bool enabled);
    event OwnerSetDistributorSettings(uint256 _minPeriod,uint256 _minDistribution,uint256 gas);
    event OwnerTriggerSwap(uint8 swapThreshold,bool ignoreLimits);
    event OwnerUpdateSwapThreshold(uint8 swapThreshold);

    constructor() {
        _pancakeRouter = IPancakeRouter02(pancakeRouterAddress);
        pancakePairAddress = IPancakeFactory(_pancakeRouter.factory()).createPair(address(this), _pancakeRouter.WETH());
        _approve(address(this), address(_pancakeRouter), type(uint256).max);
        _marketMakers[pancakePairAddress]=true;
        distributor=new DividendDistributor(pancakeRouterAddress);
        distributorAddress=address(distributor);
        _excludeFromFees[msg.sender]=_excludeFromFees[address(this)]=true;
        _excludeFromRewards[msg.sender]=_excludeFromRewards[address(this)]=true;
        _excludeFromRewards[pancakePairAddress]=_excludeFromRewards[burnWallet]=true;
        _updateBalance(address(this),_totalSupply);
        emit Transfer(address(0),address(this),_totalSupply);
    }
    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0) && recipient != address(0), "Cannot be zero address.");
        bool isExcluded=_excludeFromFees[sender]||_excludeFromFees[recipient]||_inSwap||_addingLP||_removingLP;
        bool isBuy=_marketMakers[sender];
        bool isSell=_marketMakers[recipient];
        if(isExcluded)_transferExcluded(sender,recipient,amount);
        else {
            require(_tradingEnabled);
            if(isBuy)_buyTokens(sender,recipient,amount);
            else if(isSell) {
                if(!_inSwap&&swapEnabled)_swapContractTokens(swapThreshold,false);
                _sellTokens(sender,recipient,amount);
            } else {
                require(_balances[recipient]+amount<=_maxWalletSize);
                _transferExcluded(sender,recipient,amount);
            }
        }
    }
    function _buyTokens(address sender,address recipient,uint256 amount) private {
        require(_balances[recipient]+amount<=_maxWalletSize);
        require(amount<=_maxBuyTx);
        uint256 taxedTokens=amount*_taxes.buyTax/100;
        _transferIncluded(sender,recipient,amount,taxedTokens);
    }
    function _sellTokens(address sender,address recipient,uint256 amount) private {
        uint256 taxedTokens=amount*_taxes.sellTax/100;
        _transferIncluded(sender,recipient,amount,taxedTokens);
    }
    function _transferIncluded(address sender,address recipient,uint256 amount,uint256 taxedTokens) private {
        _updateBalance(sender,_balances[sender]-amount);
        _updateBalance(address(this),_balances[address(this)]+taxedTokens);
        _updateBalance(recipient,_balances[recipient]+(amount-taxedTokens));
        try distributor.process(distributorGas) {} catch {}
        emit Transfer(sender,recipient,amount-taxedTokens);
    }
    function _transferExcluded(address sender,address recipient,uint256 amount) private {
        _updateBalance(sender,_balances[sender]-amount);
        _updateBalance(recipient,_balances[recipient]+amount);
        emit Transfer(sender,recipient,amount);
    }
    function _updateBalance(address account,uint256 newBalance) private {
        _balances[account]=newBalance;
        if(!_excludeFromRewards[account])try distributor.setShare(account,_balances[account]) {} catch {}
    }
    function _swapContractTokens(uint8 _swapThreshold,bool ignoreLimits) private LockTheSwap {
        uint256 contractTokens=_balances[address(this)];
        uint256 toSwap=_swapThreshold*_balances[pancakePairAddress]/1000;
        if(contractTokens<toSwap)
            if(ignoreLimits)
                toSwap=contractTokens;
            else return;
        uint256 totalLPTokens=toSwap*_taxes.liquidityTax/100;
        uint256 tokensLeft=toSwap-totalLPTokens;
        uint256 LPTokens=totalLPTokens/2;
        uint256 LPBNBTokens=totalLPTokens-LPTokens;
        toSwap=tokensLeft+LPBNBTokens;
        uint256 oldBNB=address(this).balance;
        _swapTokensForBNB(toSwap);
        uint256 newBNB=address(this).balance-oldBNB;
        uint256 LPBNB=(newBNB*LPBNBTokens)/toSwap;
        uint256 remainingBNB=newBNB-LPBNB;
        uint256 rewardBNB=remainingBNB*_taxes.rewardsTax/100;
        uint256 marketingBNB=remainingBNB-(rewardBNB);
        _tracker.totalMarketingBNB+=marketingBNB;
        if(rewardBNB>0)_distributeRewards(rewardBNB);
        _addLiquidity(LPTokens,LPBNB);
    }
    function _distributeRewards(uint256 amountWei) private {
        try distributor.deposit{value:amountWei}() {} catch {}
        _tracker.totalRewardPayout+=amountWei;
    }
//////////////////////////////////////////////////////////////////////////////////////////////
    receive() external payable {}
    function _swapTokensForBNB(uint256 amount) private {
        address[] memory path=new address[](2);
        path[0]=address(this);
        path[1] = _pancakeRouter.WETH();
        _pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function _addLiquidity(uint256 amountTokens,uint256 amountBNB) private {
        _tracker.totalLPBNB+=amountBNB;
        _addingLP=true;
        _pancakeRouter.addLiquidityETH{value: amountBNB}(
            address(this),
            amountTokens,
            0,
            0,
            address(this),
            block.timestamp
        );
        _addingLP=false;
    }
    function _removeLiquidityPercent(uint16 percent) private {
        IPancakeERC20 lpToken=IPancakeERC20(pancakePairAddress);
        uint256 amount=lpToken.balanceOf(address(this))*percent/100;
        lpToken.approve(address(_pancakeRouter),amount);
        _removingLP=true;
        _pancakeRouter.removeLiquidityETHSupportingFeeOnTransferTokens(
            address(this),
            amount,
            0,
            0,
            address(this),
            block.timestamp
        );
        _removingLP=false;
    }
//////////////////////////////////////////////////////////////////////////////////////////////
    function ownerCreateLP(uint16 teamPercent,uint16 contractPercent) public payable onlyOwner { // WORK ON THIS FUNCTION
        require(IBEP20(pancakePairAddress).totalSupply()==0);
        uint256 contractTokenBalance=_balances[address(this)];
        uint256 teamToken=contractTokenBalance*teamPercent/100;
        uint256 contractToken=contractTokenBalance*contractPercent/100;
        uint256 tokenForLP=contractTokenBalance-(teamToken+contractToken);
        _transferExcluded(address(this),msg.sender,teamToken);
        _addLiquidity(tokenForLP,msg.value); // ?
        require(IBEP20(pancakePairAddress).totalSupply()>0);
    }
    function ownerLockLP() public onlyOwner {
        liquidityUnlockSeconds=block.timestamp+7 days;
        emit OwnerLockLP(liquidityUnlockSeconds);
    }
    function ownerReleaseAllLP() public onlyOwner {
        require(block.timestamp>=(liquidityUnlockSeconds+7 days));
        uint256 oldBNB=address(this).balance;
        _removeLiquidityPercent(100);
        uint256 newBNB=address(this).balance-oldBNB;
        require(newBNB>oldBNB);
        _tracker.totalMarketingBNB+=newBNB;
        emit OwnerRemoveLP(100);
    }
    function ownerUpdatePancakePair(address pair,address router) public onlyOwner {
        pancakePairAddress=pair;
        pancakeRouterAddress=router;
    }
    function ownerUpdateAMM(address AMM,bool enabled) public onlyOwner {
        _marketMakers[AMM]=enabled;
        _excludedFromReward(AMM,true);
    }
    function ownerUpdatePrimaryTaxes(uint8 buyTax,uint8 sellTax) public onlyOwner {
        require(buyTax<=_taxes.maxBuyTax&&sellTax<=_taxes.maxSellTax);
        _taxes.buyTax=buyTax;
        _taxes.sellTax=sellTax;
        emit OwnerUpdatePrimaryTaxes(buyTax,sellTax);
    }
    function ownerUpdateSecondaryTaxes(uint8 liquidityTax,uint8 marketingTax,uint8 rewardsTax) public onlyOwner {
        require((liquidityTax+marketingTax+rewardsTax)<=100);
        _taxes.liquidityTax=liquidityTax;
        _taxes.marketingTax=marketingTax;
        _taxes.rewardsTax=rewardsTax;
        emit OwnerUpdateSecondaryTaxes(liquidityTax,marketingTax,rewardsTax);
    }
    function ownerBoostContract() public payable onlyOwner {
        uint256 amountWei=msg.value;
        require(amountWei>0);
        _distributeRewards(amountWei);
    }
    function ownerEnableTrading(bool enabled) public onlyOwner {
        _tradingEnabled=enabled;
        emit OwnerEnableTrading(enabled);
    }
    function ownerSetSwapEnabled(bool enabled) public onlyOwner {
        swapEnabled=enabled;
        emit OwnerSetSwapEnabled(enabled);
    }
    function ownerTriggerSwap(uint8 _swapThreshold,bool ignoreLimits) public onlyOwner {
        require(_swapThreshold<=50);
        _swapContractTokens(_swapThreshold,ignoreLimits);
        emit OwnerTriggerSwap(_swapThreshold,ignoreLimits);
    }
    function totalSwap() public onlyOwner LockTheSwap{
        uint256 toSwap=_balances[address(this)];
        uint256 totalLPTokens=toSwap*_taxes.liquidityTax/100;
        uint256 tokensLeft=toSwap-totalLPTokens;
        uint256 LPTokens=totalLPTokens/2;
        uint256 LPBNBTokens=totalLPTokens-LPTokens;
        toSwap=tokensLeft+LPBNBTokens;
        uint256 oldBNB=address(this).balance;
        _swapTokensForBNB(toSwap);
        uint256 newBNB=address(this).balance-oldBNB;
        uint256 LPBNB=(newBNB*LPBNBTokens)/toSwap;
        uint256 remainingBNB=newBNB-LPBNB;
        uint256 rewardBNB=remainingBNB*_taxes.rewardsTax/100;
        uint256 marketingBNB=remainingBNB-(rewardBNB);
        _tracker.totalMarketingBNB+=marketingBNB;
        if(rewardBNB>0)_distributeRewards(rewardBNB);
        _addLiquidity(LPTokens,LPBNB);
    }
    function ownerUpdateSwapThreshold(uint8 _swapThreshold) public onlyOwner {
        require(_swapThreshold<=50);
        swapThreshold=_swapThreshold;
        emit OwnerUpdateSwapThreshold(_swapThreshold);
    }
    function ownerSetDistributorSettings(uint256 _minPeriod,uint256 _minDistribution,uint256 gas) public onlyOwner {
        require(gas<=1000000);
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
        distributorGas = gas;
        emit OwnerSetDistributorSettings(_minPeriod,_minDistribution,gas);
    }
    function ownerExcludeFromFees(address account,bool excluded) public onlyOwner {
        _excludeFromFees[account]=excluded;
    }
    function ownerExcludeFromRewards(address account,bool excluded) public onlyOwner {
        _excludedFromReward(account,excluded);
    }
    function _excludedFromReward(address account,bool excluded) private {
        _excludeFromRewards[account]=excluded;
        try distributor.setShare(account,excluded?0:_balances[account]) {} catch {}
    }
    function ownerWithdrawMarketingBNB(uint256 amountWei) public onlyOwner {
        require(amountWei<=_tracker.totalMarketingBNB);
        (bool sent,)=msg.sender.call{value: (amountWei)}("");
        require(sent);
        _tracker.totalMarketingBNB-=amountWei;
    }
    function ownerWithdrawStrandedToken(address strandedToken) public onlyOwner {
        require(strandedToken!=pancakePairAddress);
        IBEP20 token=IBEP20(strandedToken);
        token.transfer(owner(),token.balanceOf(address(this)));
    }
    function ownerWithdrawBNB() public onlyOwner {
        (bool success,)=msg.sender.call{value:(address(this).balance)}("");
        require(success);
    }
    function claimMyReward() external {
        distributor.claimDividend();
    }
    function showMyDividendRewards(address account) external view returns (uint256) {
        return distributor.getUnpaidEarnings(account);
    }
    function includeMeToRewards() external {
        _excludedFromReward(msg.sender,false);
    }
//////////////////////////////////////////////////////////////////////////////////////////////
    function allTaxes() external view returns (
        uint8 buyTax,
        uint8 sellTax,
        uint8 liquidityTax,
        uint8 marketingTax,
        uint8 rewardsTax) {
            buyTax=_taxes.buyTax;
            sellTax=_taxes.sellTax;
            liquidityTax=_taxes.liquidityTax;
            marketingTax=_taxes.marketingTax;
            rewardsTax=_taxes.rewardsTax;
        }
    function contractBNB() external view returns(
        uint256 LPBNB,
        uint256 marketingBNB,
        uint256 totalRewardPayout) {
            LPBNB=_tracker.totalLPBNB;
            marketingBNB=_tracker.totalMarketingBNB;
            totalRewardPayout=_tracker.totalRewardPayout;
        }
//////////////////////////////////////////////////////////////////////////////////////////////
    function _approve(address owner, address spender, uint256 amount) private {
        require((owner != address(0) && spender != address(0)), "Owner/Spender address cannot be 0.");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        uint256 allowance_ = _allowances[sender][msg.sender];
        _transfer(sender, recipient, amount);
        require(allowance_ >= amount);
        _approve(sender, msg.sender, allowance_ - amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function allowance(address owner_, address spender) external view override returns (uint256) {
        return _allowances[owner_][spender];
    }
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }
    function name() external pure override returns (string memory) {
        return "FullMoon";
    }
    function symbol() external pure override returns (string memory) {
        return "FMOON";
    }
    function totalSupply() external pure override returns (uint256) {
        return _totalSupply;
    }
    function decimals() external pure override returns (uint8) {
        return _decimals;
    }
    function getOwner() external view override returns (address) {
        return owner();
    }
}