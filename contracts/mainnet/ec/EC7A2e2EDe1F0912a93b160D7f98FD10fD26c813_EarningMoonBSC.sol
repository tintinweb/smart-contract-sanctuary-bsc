/*
* TG: https://t.me/EarningMoonBSC
* Website: ....
* Author: @DaisyOfficialTG
*/
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Libraries.sol";

contract EarningMoonBSC is Ownable,IBEP20 {

    /**
    TO-DO:
        - Swap and liquify
        - Rewards
        - Read contract functions
        - Anti-bot functions
     */

    uint256 private constant _totalSupply=1_000_000_000*(10**9);
    //SWAP & LIQUIFY\\
    uint16 public swapThreshold=15;
    bool private _isSwapping;
    bool private _canSwap;
    //LP LOCK\\
    uint256 private _LPLockSeconds;
    //STRUCTS\\
    Tax private _tax;
    TaxDistribution private _taxDistribution;
    TotalBNB private _totalBNB;
    MaxLimits private _maxLimits;
    struct Tax {uint8 buyTax;uint8 sellTax;}
    struct TaxDistribution {uint16 marketingTax;uint16 rewardsTax;uint16 liquidityTax;}
    struct TotalBNB {uint256 totalMarketingBNB;uint256 totalRewardsBNB;uint256 totalRewardsPayout;uint256 totalLPBNB;}
    struct MaxLimits {uint256 maxWallet;uint256 maxBuyTx;}
    //BOOLS\\
    bool private _tradingEnabled;
    bool private _addingLP;
    bool private _removingLP;
    //MAPPINGS\\
    mapping(address=>uint256) private _balances;
    mapping(address=>mapping(address => uint256)) private _allowances;
    mapping(address=>bool) private _excludedFromFees;
    mapping(address=>bool) private _excludedFromRewards;
    mapping(address=>bool) private _automatedMarketMakers;
    //DISTRIBUTOR\\
    uint256 public distributorGas=600000;
    DividendDistributor distributor;
    address public distributorAddress;
    //PANCAKESWAP\\
    IPancakeRouter02 private _pancakeRouter;
    address public pancakeRouterAddress=0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public pancakePairAddress;
    //MISC.\\
    address public burnWallet=0x000000000000000000000000000000000000dEaD;
    //MODIFIERS\\
    modifier LockSwap {_isSwapping=true;_;_isSwapping=false;}
    modifier AddingLP {_addingLP=true;_;_addingLP=false;}
    modifier RemovingLP {_removingLP=true;_;_removingLP=false;}
    //EVENTS\\
    event OwnerEnableSwap(bool canSwap);
    event OwnerUpdateTax(uint8 buyTax,uint8 sellTax);
    event OwnerUpdateTaxDistribution(uint16 marketingTax,uint16 rewardsTax);
    event OwnerReleaseLP(uint32 LPPercent);
    event OwnerLockLP(uint256 LPLockSeconds);
    event OwnerUpdateMarketMaker(address automatedMarketMaker,bool enabled);
    event OwnerTradingEnabled(bool tradingEnabled);
    event OwnerSetDistributorSettings(uint256 _minPeriod,uint256 _minDistribution,uint256 gas);
    event OwnerWithdrawMarketingBNB(uint256 amountWei);
    event OwnerSwapAndLiquify(uint16 swapThreshold,bool ignoreLimits);
    event OwnerUpdateSwapThreshold(uint16 _swapThreshold);
    constructor() {
        _pancakeRouter = IPancakeRouter02(pancakeRouterAddress);
        pancakePairAddress=IPancakeFactory(_pancakeRouter.factory()).createPair(address(this),_pancakeRouter.WETH());
        _approve(address(this),address(_pancakeRouter),type(uint256).max);
        _automatedMarketMakers[pancakePairAddress]=true;
        distributor=new DividendDistributor(pancakeRouterAddress);
        distributorAddress=address(distributor);
        _excludedFromFees[msg.sender]=_excludedFromFees[address(this)]=true;
        _excludedFromRewards[msg.sender]=_excludedFromRewards[address(this)]=true;
        _excludedFromRewards[pancakePairAddress]=_excludedFromRewards[burnWallet]=true;
        _updateBalance(address(this),_totalSupply);
        emit Transfer(address(0),address(this),_totalSupply);
        _tax.buyTax=10;
        _tax.sellTax=15;
        _taxDistribution.marketingTax=_taxDistribution.rewardsTax=40;
        _taxDistribution.liquidityTax=20;
        _maxLimits.maxWallet=20_000_000*(10**9);
        _maxLimits.maxBuyTx=10_000_000*(10**9);
    }
    //TRANSFER FUNCTIONS\\
    function _transfer(address sender,address recipient,uint256 amount) private {
        bool isExcluded=_excludedFromFees[sender]||_excludedFromFees[recipient]||_isSwapping||_addingLP||_removingLP;
        bool isBuy=_automatedMarketMakers[sender];
        bool isSell=_automatedMarketMakers[recipient];
        uint256 taxedTokens=0;
        if(isExcluded)_doTransfer(sender,recipient,amount,taxedTokens);
        else {
            require(_tradingEnabled);
            if(isBuy){require(_balances[recipient]+amount<=_maxLimits.maxWallet);require(amount<=_maxLimits.maxBuyTx);taxedTokens=amount*_tax.buyTax/100;}
            else if(isSell){taxedTokens=amount*_tax.sellTax/100;if(!_isSwapping&&_canSwap){_swapAndLiquify(swapThreshold,false);}}
            _doTransfer(sender,recipient,amount,taxedTokens);
        }
    }
    function _doTransfer(address sender,address recipient,uint256 amount,uint256 taxedTokens) private {
        _updateBalance(sender,_balances[sender]-amount);
        if(taxedTokens>0)_updateBalance(address(this),_balances[address(this)]+taxedTokens);
        _updateBalance(recipient,_balances[recipient]+(taxedTokens>0?(amount-taxedTokens):amount));
        try distributor.process(distributorGas) {} catch {}
        emit Transfer(sender,recipient,(taxedTokens>0?(amount-taxedTokens):amount));
    }
    function _updateBalance(address account,uint256 newBalance) private {
        _balances[account]=newBalance;
        if(!_excludedFromRewards[account])try distributor.setShare(account,_balances[account]) {} catch {}
    }
    //REWARDS FUNCTION\\
    function _distributeRewards(uint256 amountWei) private {
        try distributor.deposit{value:amountWei}() {} catch {}
        _totalBNB.totalRewardsPayout+=amountWei;
    }
    //LIQUIDITY FUNCTIONS\\
    function _swapAndLiquify(uint16 _swapThreshold,bool ignoreLimits) private LockSwap {
        uint256 contractTokens=_balances[address(this)];
        uint256 toSwap=_swapThreshold*_balances[pancakePairAddress]/1000;
        if(contractTokens<toSwap)
            if(ignoreLimits)
                toSwap=contractTokens;
            else return;
        uint256 totalLPTokens=toSwap*_taxDistribution.liquidityTax/100;
        uint256 tokensLeft=toSwap-totalLPTokens;
        uint256 LPTokens=totalLPTokens/2;
        uint256 LPBNBTokens=totalLPTokens-LPTokens;
        toSwap=tokensLeft+LPBNBTokens;
        uint256 oldBNB=address(this).balance;
        _swapTokensForBNB(toSwap);
        uint256 newBNB=address(this).balance-oldBNB;
        uint256 LPBNB=(newBNB*LPBNBTokens)/toSwap;
        uint256 remainingBNB=newBNB-LPBNB;
        uint256 marketingBNB=remainingBNB*_taxDistribution.marketingTax/100;
        uint256 rewardsBNB=remainingBNB-marketingBNB;
        _totalBNB.totalMarketingBNB+=marketingBNB;
        _totalBNB.totalRewardsBNB+=rewardsBNB;
        if(rewardsBNB>0)_distributeRewards(rewardsBNB);
        _addLiquidity(LPTokens,LPBNB);
    }
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
    function _addLiquidity(uint256 amountTokens,uint256 amountBNB) private AddingLP {
        _totalBNB.totalLPBNB+=amountBNB;
        _pancakeRouter.addLiquidityETH{value: amountBNB}(
            address(this),
            amountTokens,
            0,
            0,
            address(this),
            block.timestamp
        );
    }
    function _removeLiquidityPercent(uint32 percent) private RemovingLP {
        IPancakeERC20 lpToken=IPancakeERC20(pancakePairAddress);
        uint256 amount=lpToken.balanceOf(address(this))*percent/100;
        lpToken.approve(address(_pancakeRouter),amount);
        _pancakeRouter.removeLiquidityETHSupportingFeeOnTransferTokens(
            address(this),
            amount,
            0,
            0,
            address(this),
            block.timestamp
        );
    }
    //OWNER FUNCTIONS\\
    function ownerCreateLP(uint16 teamPercent,uint16 contractPercent) public payable onlyOwner { // WORK ON THIS FUNCTION
        require(IBEP20(pancakePairAddress).totalSupply()==0);
        uint256 contractTokenBalance=_balances[address(this)];
        uint256 teamToken=contractTokenBalance*teamPercent/100;
        uint256 contractToken=contractTokenBalance*contractPercent/100;
        uint256 tokenForLP=contractTokenBalance-(teamToken+contractToken);
        _doTransfer(address(this),msg.sender,teamToken,0); 
        _addLiquidity(tokenForLP,msg.value); // ?
        require(IBEP20(pancakePairAddress).totalSupply()>0);
    }
    function ownerLockLP() public onlyOwner {
        _LPLockSeconds=block.timestamp+7 days;
        emit OwnerLockLP(_LPLockSeconds);
    }
    function ownerReleaseLP() public onlyOwner {
        require(block.timestamp>=(_LPLockSeconds+7 days));
        uint256 oldBNB=address(this).balance;
        _removeLiquidityPercent(100);
        uint256 newBNB=address(this).balance-oldBNB;
        require(newBNB>oldBNB);
        _totalBNB.totalMarketingBNB+=newBNB;
        emit OwnerReleaseLP(100);
    }
    function ownerBoostRewards() public payable onlyOwner {
        require(msg.value>0);
        _distributeRewards(msg.value);
    }
    function ownerUpdateAutomatedMarketMaker(address automatedMarketMaker,bool enabled) public onlyOwner {
        _automatedMarketMakers[automatedMarketMaker]=enabled;
        ownerExcludeFromRewards(automatedMarketMaker,true);
        emit OwnerUpdateMarketMaker(automatedMarketMaker,enabled);
    }
    function ownerUpdatePair(address newPair,address newRouter) public onlyOwner {
        pancakePairAddress=newPair;
        pancakeRouterAddress=newRouter;
    }
    function ownerUpdateTax(uint8 buyTax,uint8 sellTax) public onlyOwner {
        require(buyTax<=10&&sellTax<=15);
        _tax.buyTax=buyTax;
        _tax.sellTax=sellTax;
        emit OwnerUpdateTax(buyTax,sellTax);
    }
    function ownerUpdateTaxDistribution(uint16 marketingTax,uint16 rewardsTax,uint16 liquidityTax) public onlyOwner {
        require((marketingTax+rewardsTax+liquidityTax)==100);
        _taxDistribution.marketingTax=marketingTax;
        _taxDistribution.rewardsTax=rewardsTax;
        _taxDistribution.liquidityTax=liquidityTax;
        emit OwnerUpdateTaxDistribution(marketingTax,rewardsTax);
    }
    function ownerEnableSwap(bool canSwap) public onlyOwner {
        _canSwap=canSwap;
        emit OwnerEnableSwap(canSwap);
    }
    function ownerUpdateSwapThreshold(uint16 _swapThreshold) public onlyOwner {
        swapThreshold=_swapThreshold;
        emit OwnerUpdateSwapThreshold(_swapThreshold);
    }
    function ownerTriggerSwap(uint16 _swapThreshold,bool ignoreLimits) public onlyOwner {
        _swapAndLiquify(_swapThreshold,ignoreLimits);
        emit OwnerSwapAndLiquify(swapThreshold,ignoreLimits);
    }
    function ownerEnableTrading(bool tradingEnabled) public onlyOwner {
        _tradingEnabled=tradingEnabled;
        emit OwnerTradingEnabled(tradingEnabled);
    }
    function ownerSetDistributorSettings(uint256 _minPeriod,uint256 _minDistribution,uint256 gas) public onlyOwner {
        require(gas<=1000000);
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
        distributorGas = gas;
        emit OwnerSetDistributorSettings(_minPeriod,_minDistribution,gas);
    }
    function ownerExcludeFromFees(address account,bool excluded) public onlyOwner {
        _excludedFromFees[account]=excluded;
    }
    function ownerExcludeFromRewards(address account,bool excluded) public onlyOwner {
        _excludedFromRewards[account]=excluded;
        try distributor.setShare(account,excluded?0:_balances[account]) {} catch {}
    }
    function ownerWithdrawStrandedToken(address strandedToken) public onlyOwner {
        require(strandedToken!=pancakePairAddress&&strandedToken!=address(this));
        IBEP20 token=IBEP20(strandedToken);
        token.transfer(owner(),token.balanceOf(address(this)));
    }
    function ownerWithdrawBNB() public onlyOwner {
        (bool success,)=msg.sender.call{value:(address(this).balance)}("");
        require(success);
    }
    function ownerWithdrawMarketingBNB(uint256 amountWei) public onlyOwner {
        require(amountWei<=_totalBNB.totalMarketingBNB);
        (bool sent,)=msg.sender.call{value: (amountWei)}("");
        require(sent);
        _totalBNB.totalMarketingBNB-=amountWei;
        emit OwnerWithdrawMarketingBNB(amountWei);
    }
    function claimMyReward() external {
        distributor.claimDividend();
    }
    function showMyDividendRewards(address account) external view returns (uint256) {
        return distributor.getUnpaidEarnings(account);
    }
    //READ FUNCTIONS\\
    function showTransactionTax() external view returns(uint8 buyTax,uint8 sellTax) {
        buyTax=_tax.buyTax;
        sellTax=_tax.sellTax;
    }
    function showDistributionTax() external view returns(
        uint16 marketingTax,
        uint16 rewardsTax,
        uint16 liquidityTax) {
            marketingTax=_taxDistribution.marketingTax;
            rewardsTax=_taxDistribution.rewardsTax;
            liquidityTax=_taxDistribution.liquidityTax;
    }
    function ShowLPLockSeconds() external view returns(uint256) {
        return _LPLockSeconds>block.timestamp?_LPLockSeconds-block.timestamp:0;
    }
    function showContractBNB() external view returns(
        uint256 marketingBNB,
        uint256 rewardsBNB,
        uint256 rewardsPayout,
        uint256 LPBNB) {
            marketingBNB=_totalBNB.totalMarketingBNB;
            rewardsBNB=_totalBNB.totalRewardsBNB;
            rewardsPayout=_totalBNB.totalRewardsPayout;
            LPBNB=_totalBNB.totalLPBNB;
    }
    //IBEP20\\
    function _approve(address owner, address spender, uint256 amount) private {
        require((owner != address(0) && spender != address(0)), "Owner/Spender address cannot be 0.");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function transferFrom(address sender,address recipient,uint256 amount) external override returns (bool) {
        uint256 allowance_ = _allowances[sender][msg.sender];
        _transfer(sender, recipient, amount);
        require(allowance_ >= amount);
        _approve(sender, msg.sender, allowance_ - amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    function approve(address spender,uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function allowance(address owner_,address spender) external view override returns (uint256) {
        return _allowances[owner_][spender];
    }
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }
    function name() external pure override returns (string memory) {
        return "EarningMoon";
    }
    function symbol() external pure override returns (string memory) {
        return "EMOON";
    }
    function totalSupply() external pure override returns (uint256) {
        return _totalSupply;
    }
    function decimals() external pure override returns (uint8) {
        return 9;
    }
    function getOwner() external view override returns (address) {
        return owner();
    }
    receive() external payable {require(msg.sender==owner());}
}