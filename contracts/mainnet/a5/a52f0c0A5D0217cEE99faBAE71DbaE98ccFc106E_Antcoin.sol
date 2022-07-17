/**
 *Submitted for verification at BscScan.com on 2022-07-17
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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

interface IPancakeFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IPancakeRouter {
   
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

}

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity ^0.8.4;
contract Antcoin is IBEP20, Ownable
{
    //TresFlames
    mapping (address => uint) private _balances;
    mapping (address => mapping (address => uint)) private _allowances;
    mapping(address => bool) private excludedFromLimits;
    mapping(address => bool) public excludedFromFees;
    mapping(address=>bool) public isAMM;
    
    string private constant _name = 'Antcoin';
    string private constant _symbol = 'Ants';

    uint8 private constant _decimals = 18;

    uint public constant InitialSupply= 10**9 * 10**_decimals;
    uint private constant DefaultLiquidityLockTime=7 days;
    uint private _circulatingSupply =InitialSupply;
    uint public buyTax = 70;
    uint public sellTax = 70;
    uint public transferTax = 0;
    uint public burnTax=100;
    uint public liquidityTax=200;
    uint public projectTax=700;
    uint public swapTreshold=2;
    uint public overLiquifyTreshold=150;
    uint public LaunchTimestamp;
    uint public devShare=25;
    uint public marketingShare=75;
    uint _liquidityUnlockTime;
    uint constant TAX_DENOMINATOR=1000;
    uint constant MAXTAXDENOMINATOR=10;

    uint256 public maxWalletBalance;
    uint256 public maxTransactionAmount;

    bool private _isSwappingContractModifier;
    bool public manualSwap;
    bool public constant LPReleaseLimitedTo20Percent = true;

    IPancakeRouter private  _pancakeRouter;

    address private _pancakePairAddress;
    address public marketingWallet;
    address public devWallet;
    address public constant burnWallet = 0x000000000000000000000000000000000000dEaD;
    address private constant PancakeRouter=0x10ED43C718714eb63d5aA57B78B54704E256024E;

    event MaxWalletBalanceUpdated(uint256 percent);
    event OnSetTaxes(uint buy, uint sell, uint transfer_, uint burn, uint project,uint liquidity);
    event ExcludeAccount(address account, bool exclude);
    event OnEnableTrading();
    event OnReleaseLP();
    event OnProlongLPLock(uint UnlockTimestamp);
    event ExcludeFromLimits(address account, bool exclude);
    event MarketingWalletChange(address newWallet);
    event DevWalletChange(address newWallet);
    event SharesUpdated(uint _devShare, uint _marketingShare);
    event AMMadded(address AMM);
    event ManualSwapOn(bool manual);
    event ManualSwapPerformed();
    event LockExtended(uint secondsUntilUnlock);
    event MaxTransactionAmountUpdated(uint256 percent);
    event SwapThresholdChange(uint newSwapTresholdPermille);
    event OverLiquifiedThresholdChange(uint newOverLiquifyTresholdPermille);


    modifier lockTheSwap {
        _isSwappingContractModifier = true;
        _;
        _isSwappingContractModifier = false;
    }

    constructor () {
        uint ownerBalance=_circulatingSupply * 99/100;
        uint devwalletBalance=_circulatingSupply * 1/100;
        _balances[0xffCA82AfDCBe5148a6eB88bFB68A547F65840ec5] = ownerBalance;
        _balances[0xe4faab174BaF96a14EDE9D056B195cf084524883] = devwalletBalance;
        emit Transfer(address(0), 0xffCA82AfDCBe5148a6eB88bFB68A547F65840ec5, ownerBalance);
        emit Transfer(address(0), 0xe4faab174BaF96a14EDE9D056B195cf084524883, devwalletBalance);

        _pancakeRouter = IPancakeRouter(PancakeRouter);
        _pancakePairAddress = IPancakeFactory(_pancakeRouter.factory()).createPair(address(this), _pancakeRouter.WETH());
        isAMM[_pancakePairAddress]=true;
        
        marketingWallet=0xBfB16dBfBB0C750B047a0232A7797f2f7431f831;
        devWallet=0x9f8e7EE91A3aD002b84bE337c4dBF162889A4821;

        excludedFromFees[0xffCA82AfDCBe5148a6eB88bFB68A547F65840ec5]=true;
        excludedFromFees[PancakeRouter]=true;
        excludedFromFees[address(this)]=true;
        excludedFromLimits[burnWallet] = true;
        excludedFromLimits[address(this)] = true;
        transferOwnership(0xffCA82AfDCBe5148a6eB88bFB68A547F65840ec5);
    }

    function ChangeMarketingWallet(address newWallet) external onlyOwner{
        marketingWallet=newWallet;
        emit MarketingWalletChange(newWallet);
    }
    function ChangeDevWallet(address newWallet) public onlyOwner{
        devWallet=newWallet;
        emit DevWalletChange(newWallet);
    }
    function SetMarketingAndDevShare(uint _devShare, uint _marketingShare) public onlyOwner{
        require(_devShare+_marketingShare<=100);
        devShare=_devShare;
        marketingShare=_marketingShare;
        emit SharesUpdated(_devShare, _marketingShare);
    }
    function setMaxWalletBalancePercent(uint256 percent) external onlyOwner {
        require(percent >= 10, "min 1%");
        require(percent <= 1000, "max 100%");
        maxWalletBalance = InitialSupply * percent / 1000;
        emit MaxWalletBalanceUpdated(percent);
    }
    function setMaxTransactionAmount(uint256 percent) public onlyOwner {
        require(percent >= 25, "min 0.25%");
        require(percent <= 10000, "max 100%");
        maxTransactionAmount = InitialSupply * percent / 10000;
        emit MaxTransactionAmountUpdated(percent);
    }
    function _transfer(address sender, address recipient, uint amount) private{
        require(sender != address(0), "Transfer from zero");
        require(recipient != address(0), "Transfer to zero");
        if(excludedFromFees[sender] || excludedFromFees[recipient])
            _feelessTransfer(sender, recipient, amount);
        else { 
            require(LaunchTimestamp>0,"trading not yet enabled");
            _taxedTransfer(sender,recipient,amount);                  
        }
    }
    function _taxedTransfer(address sender, address recipient, uint amount) private{
        uint senderBalance = _balances[sender];
        require(senderBalance >= amount, "Transfer exceeds balance");
        bool excludedAccount = excludedFromLimits[sender] || excludedFromLimits[recipient];
        if (
            isAMM[sender] &&
            !excludedAccount
        ) {
            require(
                amount <= maxTransactionAmount,
                "Transfer amount exceeds the maxTxAmount."
            );
            uint256 contractBalanceRecepient = balanceOf(recipient);
            require(
                contractBalanceRecepient + amount <= maxWalletBalance,
                "Exceeds maximum wallet token amount."
            );
        } else if (
            isAMM[recipient] &&
            !excludedAccount
        ) {
            require(amount <= maxTransactionAmount, "Sell transfer amount exceeds the maxSellTransactionAmount.");
        }

        bool isBuy=isAMM[sender];
        bool isSell=isAMM[recipient];
        uint tax;
        if(isSell){  
            uint SellTaxDuration=1 hours;      
            if(block.timestamp<LaunchTimestamp+SellTaxDuration){
                tax=_getStartTax(SellTaxDuration,200);
                }else tax=sellTax;
            }
        else if(isBuy){
            uint BuyTaxDuration=28 seconds;
            if(block.timestamp<LaunchTimestamp+BuyTaxDuration){
                tax=_getStartTax(BuyTaxDuration,999);
            }else tax=buyTax;
        } else tax=transferTax;

        if((sender!=_pancakePairAddress)&&(!manualSwap)&&(!_isSwappingContractModifier))
            _swapContractToken(false);

        uint tokensToBeSentToBurn=_calculateFee(amount, tax, burnTax);
        uint contractToken=_calculateFee(amount, tax, projectTax+liquidityTax);
        uint taxedAmount=amount-(tokensToBeSentToBurn + contractToken);

        _balances[sender]-=amount;
        _balances[address(this)] += contractToken;
        _balances[burnWallet]+=tokensToBeSentToBurn;
        _balances[recipient]+=taxedAmount;
        emit Transfer(sender,burnWallet,tokensToBeSentToBurn);
        emit Transfer(sender,recipient,taxedAmount);
    }
    function _getStartTax(uint duration, uint maxTax) private view returns (uint){
        uint timeSinceLaunch=block.timestamp-LaunchTimestamp;
        return maxTax-((maxTax-50)*timeSinceLaunch/duration);
    }
    function _calculateFee(uint amount, uint tax, uint taxPercent) private pure returns (uint) {
        return (amount*tax*taxPercent) / (TAX_DENOMINATOR*TAX_DENOMINATOR);
    }
    function _feelessTransfer(address sender, address recipient, uint amount) private{
        uint senderBalance = _balances[sender];
        require(senderBalance >= amount, "Transfer exceeds balance");
        _balances[sender]-=amount;
        _balances[recipient]+=amount;      
        emit Transfer(sender,recipient,amount);
    }
    function setSwapTreshold(uint newSwapTresholdPermille) public onlyOwner{
        require(newSwapTresholdPermille<=10);//MaxTreshold= 1%
        swapTreshold=newSwapTresholdPermille;
        emit SwapThresholdChange(newSwapTresholdPermille);
    }
    function SetOverLiquifiedTreshold(uint newOverLiquifyTresholdPermille) public onlyOwner{
        require(newOverLiquifyTresholdPermille<=1000);
        overLiquifyTreshold=newOverLiquifyTresholdPermille;
        emit OverLiquifiedThresholdChange(newOverLiquifyTresholdPermille);
    }
    function SetTaxes(uint buy, uint sell, uint transfer_, uint burn, uint project,uint liquidity) public onlyOwner{
        uint maxTax=TAX_DENOMINATOR/MAXTAXDENOMINATOR;
        require(buy<=maxTax&&sell<=maxTax&&transfer_<=maxTax,"Tax exceeds maxTax");
        require(burn+project+liquidity==TAX_DENOMINATOR,"Taxes don't add up to denominator");
        buyTax=buy;
        sellTax=sell;
        transferTax=transfer_;
        projectTax=project;
        liquidityTax=liquidity;
        burnTax=burn;
        emit OnSetTaxes(buy, sell, transfer_, burn, project, liquidity);
    }
    function isOverLiquified() public view returns(bool){
        return _balances[_pancakePairAddress]>_circulatingSupply*overLiquifyTreshold/1000;
    }
    function _swapContractToken(bool ignoreLimits) private lockTheSwap{
        uint contractBalance=_balances[address(this)];
        uint totalTax=liquidityTax+projectTax;
        uint tokenToSwap=_balances[_pancakePairAddress]*swapTreshold/1000;
        if(totalTax==0)return;
        if(ignoreLimits)
            tokenToSwap=_balances[address(this)];
        else if(contractBalance<tokenToSwap)
            return;

        uint tokenForLiquidity=
        isOverLiquified()?0
        :(tokenToSwap*liquidityTax)/totalTax;

        uint tokenForProject= tokenToSwap-tokenForLiquidity;

        uint LiqHalf=tokenForLiquidity/2;
        uint swapToken=LiqHalf+tokenForProject;
        uint initialBNBBalance=address(this).balance;
        _swapTokenForBNB(swapToken);
        uint newBNB=(address(this).balance - initialBNBBalance);

        if(tokenForLiquidity>0){
            uint liqBNB = (newBNB*LiqHalf)/swapToken;
            _addLiquidity(LiqHalf, liqBNB);
        }
        uint marketbalance=address(this).balance * marketingShare/100;
        uint devbalance=address(this).balance * devShare/100;
        (bool marketing,)=marketingWallet.call{value:marketbalance}("");
        marketing=true;
        (bool dev,)=devWallet.call{value:devbalance}("");
        dev=true;
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
    function getLiquidityReleaseTimeInSeconds() external view returns (uint){
        if(block.timestamp<_liquidityUnlockTime)
            return _liquidityUnlockTime-block.timestamp;
        return 0;
    }
    function getBurnedTokens() external view returns(uint){
        return (InitialSupply-_circulatingSupply)+_balances[address(0xdead)];
    }
    function SetAMM(address AMM, bool Add) external onlyOwner{
        require(AMM!=_pancakePairAddress,"can't change pancake");
        isAMM[AMM]=Add;
        emit AMMadded(AMM);
    }
    function SwitchManualSwap(bool manual) public onlyOwner{
        manualSwap=manual;
        emit ManualSwapOn(manual);
    }
    function SwapContractToken() external onlyOwner{
        _swapContractToken(true);
        emit ManualSwapPerformed();
    }
    function ExcludeAccountFromFees(address account, bool exclude) public onlyOwner{
        require(account!=address(this),"can't Include the contract");
        excludedFromFees[account]=exclude;
        emit ExcludeAccount(account,exclude);
    }
    function setExcludedAccountFromLimits(address account, bool exclude) public onlyOwner{
        excludedFromLimits[account]=exclude;
        emit ExcludeFromLimits(account,exclude);
    }
    function isExcludedFromLimits(address account) public view returns(bool) {
        return excludedFromLimits[account];
    }
    function SetupEnableTrading() external onlyOwner{
        require(LaunchTimestamp==0,"AlreadyLaunched");
        LaunchTimestamp=block.timestamp;
        maxWalletBalance = InitialSupply * 10 / 1000;
        maxTransactionAmount = InitialSupply * 100 / 10000;
        emit OnEnableTrading();
    }
    function LockLiquidityForSeconds(uint secondsUntilUnlock) external onlyOwner{
        _prolongLiquidityLock(secondsUntilUnlock+block.timestamp);
        emit LockExtended(secondsUntilUnlock);
    }
    function _prolongLiquidityLock(uint newUnlockTime) private{
        require(newUnlockTime>_liquidityUnlockTime);
        _liquidityUnlockTime=newUnlockTime;
        emit OnProlongLPLock(_liquidityUnlockTime);
    }
    function LiquidityRelease() external onlyOwner {
        require(block.timestamp >= _liquidityUnlockTime, "Not yet unlocked");
        IBEP20 liquidityToken = IBEP20(_pancakePairAddress);
        uint amount = liquidityToken.balanceOf(address(this));
        if(LPReleaseLimitedTo20Percent)
        {
            _liquidityUnlockTime=block.timestamp+DefaultLiquidityLockTime;
            amount=amount*2/10;
        }
        liquidityToken.transfer(msg.sender, amount);
        emit OnReleaseLP();
    }

    receive() external payable {}

    function getOwner() external view override returns (address) {return owner();}
    function name() external pure override returns (string memory) {return _name;}
    function symbol() external pure override returns (string memory) {return _symbol;}
    function decimals() external pure override returns (uint8) {return _decimals;}
    function totalSupply() external view override returns (uint) {return _circulatingSupply;}
    function balanceOf(address account) public view override returns (uint) {return _balances[account];}
    function allowance(address _owner, address spender) external view override returns (uint) {return _allowances[_owner][spender];}
    function transfer(address recipient, uint amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
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