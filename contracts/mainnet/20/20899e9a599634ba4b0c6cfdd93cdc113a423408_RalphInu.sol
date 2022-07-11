/**
 *Submitted for verification at BscScan.com on 2022-07-11
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IdexRouter {
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
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

}
interface IdexFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IERC20 {
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
interface ILiquifyManager {
    function refundTo() external returns(uint256);
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

contract RalphInu is IERC20, Ownable
{
    //TresFlames
    //mapping
    mapping (address => uint) private _balances;
    mapping (address => mapping (address => uint)) private _allowances;
    mapping(address => bool) private excludedFromLimits;
    mapping(address => bool) public excludedFromFees;
    mapping(address=>bool) public isPair;
    mapping (address => bool) public isBlacklisted;
    //strings
    string private constant _name = 'Ralph Inu';
    string private constant _symbol = '$RINU';
    //uints
    uint private constant DefaultLiquidityLockTime=7 days;
    uint public constant InitialSupply= 10**8 * 10**_decimals;
    uint public _circulatingSupply =InitialSupply;
    uint public buyTax = 100;
    uint public sellTax = 100;
    uint public transferTax = 10;
    uint public liquidityTax=200;
    uint public projectTax=800;
    uint constant TAX_DENOMINATOR=1000;
    uint constant MAXTAXDENOMINATOR=10;
    uint public swapTreshold=5;
    uint public overLiquifyTreshold=60;
    uint private LaunchTimestamp;
    uint _liquidityUnlockTime;
    uint marketShare=50;
    uint teamShare=40;
    uint8 private constant _decimals = 18;
    uint256 public maxTransactionAmount;
    uint256 public maxWalletBalance;

    IdexRouter private  _dexRouter;
    ILiquifyManager private _liquifyManager;
    
    //addresses
    // address private dexRouter=0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;    // uniswap address
    address private dexRouter=0x10ED43C718714eb63d5aA57B78B54704E256024E; //pancake addresss
    address private _dexPairAddress;
    address constant deadWallet = 0x000000000000000000000000000000000000dEaD;
    address public devWallet;
    address public marketingWallet;
    address public teamWallet;
    address private pairToken;
    //modifiers

    modifier lockTheSwap {
        _isSwappingContractModifier = true;
        _;
        _isSwappingContractModifier = false;
    }

    //bools
    bool private _isSwappingContractModifier;
    bool public blacklistMode = true;
    bool public manualSwap;
    bool public LPReleaseLimitedTo20Percent;
    
    //events
    event BlacklistStatusChange(bool status);
    event UpdateMarketingWallet(address _address);
    event UpdateTeamWallet(address _address);
    event SwapThresholdChange(uint threshold);
    event OverLiquifiedThresholdChange(uint threshold);
    event OnSetTaxes(uint buy, uint sell, uint transfer_, uint project,uint liquidity);
    event ManualSwapChange(bool status);
    event MaxWalletBalanceUpdated(uint256 percent);
    event MaxTransactionAmountUpdated(uint256 percent);
    event ExcludeAccount(address account, bool exclude);
    event ExcludeFromLimits(address account, bool exclude);
    event OwnerSwap();
    event OnEnableTrading();
    event OnProlongLPLock(uint UnlockTimestamp);
    event OnReleaseLP();
    event RecoverToken();
    event BlacklistUpdated();
    event NewPairSet(address Pair, bool Add);
    event Release20PercentLP();
    event NewRouterSet(address _newdex);
    event MarketShareUpdate(uint _marketshare, uint _teamShare);
    event RecoverBNB();
    
    constructor (address pairToken_, address liquifyManager_) {
        uint deployerBalance=_circulatingSupply;
        _balances[msg.sender] = deployerBalance;
        emit Transfer(address(0), msg.sender, deployerBalance);
        pairToken = pairToken_;
        _dexRouter = IdexRouter(dexRouter);
        _liquifyManager = ILiquifyManager(liquifyManager_);
        _dexPairAddress = IdexFactory(_dexRouter.factory()).createPair(address(this), pairToken_);
        isPair[_dexPairAddress]=true;

        devWallet = 0x85E837645a38BEeB612E55995AbBf93277E663C0;
        marketingWallet = 0x7e043eAd383f32632D4DEB1283B2dFe64c052a2C;
        teamWallet = 0x2c9bF8dB1a5befb103A4eb89B9a657E056902d01;

        excludedFromFees[msg.sender]=true;
        excludedFromFees[dexRouter]=true;
        excludedFromFees[address(this)]=true;
        excludedFromLimits[msg.sender] = true;
        excludedFromLimits[deadWallet] = true;
        excludedFromLimits[address(this)] = true;
    }
    
    function enable_blacklist(bool _status) public onlyOwner {
        blacklistMode = _status;
        emit BlacklistStatusChange (_status);
    }
    function manage_blacklist(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            isBlacklisted[addresses[i]] = status;
        }
        emit BlacklistUpdated();
    }
    function ChangeMarketingWallet(address newAddress) public onlyOwner{
        marketingWallet=newAddress;
        emit UpdateMarketingWallet(newAddress);
    }
    function ChangeTeamWallet(address newAddress) public onlyOwner{
        teamWallet=newAddress;
        emit UpdateTeamWallet(newAddress);
    }
    function _transfer(address sender, address recipient, uint amount) private{
        require(sender != address(0), "Transfer from zero");
        require(recipient != address(0), "Transfer to zero");
        if(blacklistMode){
            require(!isBlacklisted[sender] && !isBlacklisted[recipient],"Blacklisted");    
        }
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
            isPair[sender] &&
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
            isPair[recipient] &&
            !excludedAccount
        ) {
            require(amount <= maxTransactionAmount, "Sell transfer amount exceeds the maxSellTransactionAmount.");
        }

        bool isBuy=isPair[sender];
        bool isSell=isPair[recipient];
        uint tax;
        if(isSell){  
            uint SellTaxDuration=25 minutes;          
            if(block.timestamp<LaunchTimestamp+SellTaxDuration){
                tax=_getStartTax(SellTaxDuration,200);
            } else tax=sellTax;
        }
        else if(isBuy){
            uint BuyTaxDuration=28 seconds;
            if(block.timestamp<LaunchTimestamp+BuyTaxDuration){
                tax=_getStartTax(BuyTaxDuration,999);
            }else tax=buyTax;
        } else tax=transferTax;

        if((sender!=_dexPairAddress)&&(!manualSwap)&&(!_isSwappingContractModifier))
            _swapContractToken(false);
        uint contractToken=_calculateFee(amount, tax, projectTax+liquidityTax);
        uint taxedAmount=amount-contractToken;

        _balances[sender]-=amount;
        _balances[address(this)] += contractToken;
        _balances[recipient]+=taxedAmount;
        
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
    function SetTaxes(uint buy, uint sell, uint transfer_, uint project,uint liquidity) public onlyOwner{
        uint maxTax=200;
        require(buy<=maxTax&&sell<=maxTax&&transfer_<=maxTax,"Tax exceeds maxTax");
        require(project+liquidity==TAX_DENOMINATOR,"Taxes don't add up to denominator");
        
        buyTax=buy;
        sellTax=sell;
        transferTax=transfer_;
        projectTax=project;
        liquidityTax=liquidity;
        emit OnSetTaxes(buy, sell, transfer_, project,liquidity);
    }
    function SetShares(uint _marketShare, uint _teamShare) public onlyOwner{
        require(_marketShare+_teamShare<=90);
        marketShare = _marketShare;
        teamShare = _teamShare;
        emit MarketShareUpdate(_marketShare, _teamShare);
    }
    function isOverLiquified() public view returns(bool){
        return _balances[_dexPairAddress]>_circulatingSupply*overLiquifyTreshold/1000;
    }
    function _swapContractToken(bool ignoreLimits) private lockTheSwap{
        uint contractBalance=_balances[address(this)];
        uint totalTax=liquidityTax+projectTax;
        uint tokenToSwap=_balances[_dexPairAddress]*swapTreshold/1000;

        if(totalTax==0)return;
        if(ignoreLimits)
            tokenToSwap=_balances[address(this)];
        else if(contractBalance<tokenToSwap)
            return;
        uint tokenForLiquidity=isOverLiquified()?0:(tokenToSwap*liquidityTax)/totalTax;

        uint tokenForProject= tokenToSwap-tokenForLiquidity;

        uint LiqHalf=tokenForLiquidity/2;
        uint swapToken=LiqHalf+tokenForProject;
        IERC20 token = IERC20(pairToken);
        uint initialBalance = token.balanceOf(address(this));
        _swapTokenForToken(swapToken);
        uint newBalance = token.balanceOf(address(this)) - initialBalance;
        if(tokenForLiquidity>0){
            uint liqToken = (newBalance*LiqHalf)/swapToken;
            _addLiquidity(LiqHalf, liqToken);
        }

        uint bal1 = token.balanceOf(address(this)) * 10/100;
        uint bal2 = token.balanceOf(address(this)) * marketShare/100;
        uint bal3 = token.balanceOf(address(this)) * teamShare/100;
        require (token.transfer(devWallet, bal1), 'transaction failed');
        require (token.transfer(marketingWallet, bal2), 'transaction failed');
        require (token.transfer(teamWallet, bal3), 'transaction failed');
        
    }
    function _swapTokenForToken(uint amount) private {
        _approve(address(this), address(_dexRouter), amount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pairToken;

        _dexRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(_liquifyManager),
            block.timestamp
        );

        _liquifyManager.refundTo();
    }
    function _addLiquidity(uint tokenAmount, uint pairAmount) private {
        _approve(address(this), address(_dexRouter), tokenAmount);
        IERC20(pairToken).approve(address(_dexRouter), pairAmount);
        _dexRouter.addLiquidity(
            address(this),
            pairToken,
            tokenAmount,
            pairAmount,
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
    function SetPair(address Pair, bool Add) public onlyOwner{
        require(Pair!=_dexPairAddress,"can't change pancake");
        isPair[Pair]=Add;
        emit NewPairSet(Pair,Add);
    }
    function SwitchManualSwap(bool manual) public onlyOwner{
        manualSwap=manual;
        emit ManualSwapChange(manual);
    }
    function SwapContractToken() public onlyOwner{
        _swapContractToken(true);
        emit OwnerSwap();
    }
    function SetNewRouter(address _newdex) public onlyOwner{
        dexRouter = _newdex;
        emit NewRouterSet(_newdex);
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
    
    function SetupEnableTrading() public onlyOwner{
        require(LaunchTimestamp==0,"AlreadyLaunched");
        LaunchTimestamp=block.timestamp;
        maxWalletBalance = InitialSupply * 10 / 1000;
        maxTransactionAmount = InitialSupply * 100 / 10000;
        emit OnEnableTrading();
    }
    
    function limitLiquidityReleaseTo20Percent() public onlyOwner{
        LPReleaseLimitedTo20Percent=true;
        emit Release20PercentLP();
    }
    function LockLiquidityForSeconds(uint secondsUntilUnlock) public onlyOwner{
        _prolongLiquidityLock(secondsUntilUnlock+block.timestamp);
    }
    function _prolongLiquidityLock(uint newUnlockTime) private{
        require(newUnlockTime>_liquidityUnlockTime);
        _liquidityUnlockTime=newUnlockTime;
        emit OnProlongLPLock(_liquidityUnlockTime);
    }
    
    function LiquidityRelease() public onlyOwner {
        require(block.timestamp >= _liquidityUnlockTime, "Not yet unlocked");

        IERC20 liquidityToken = IERC20(_dexPairAddress);
        uint amount = liquidityToken.balanceOf(address(this));
        if(LPReleaseLimitedTo20Percent)
        {
            _liquidityUnlockTime=block.timestamp+DefaultLiquidityLockTime;
            amount=amount*2/10;
        }
        liquidityToken.transfer(msg.sender, amount);
        emit OnReleaseLP();
    }

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
    function balanceOf(address account) public view override returns (uint) {
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
    function emergencyTokenrecovery(address tokenAddr, uint256 amountPercentage) external onlyOwner {
        require(tokenAddr != pairToken);
        IERC20 token = IERC20(tokenAddr);
        uint256 tokenAmount = token.balanceOf(address(this));
        require (token.transfer(msg.sender, tokenAmount * amountPercentage / 100), 'transaction failed');
        emit RecoverToken();
    }
    function emergencyBNBrecovery(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
        emit RecoverBNB();
    }

    receive() external payable {}

}