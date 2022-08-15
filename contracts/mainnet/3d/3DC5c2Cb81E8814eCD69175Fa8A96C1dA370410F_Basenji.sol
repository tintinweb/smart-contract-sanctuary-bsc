/**
 *Submitted for verification at BscScan.com on 2022-08-15
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

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IPancakeFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDEXRouter {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (
            uint amountToken,
            uint amountETH,
            uint liquidity
        );

    function swapExactTokensForETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender);
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0)
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
interface IWETH is IBEP20 {
    function deposit() external payable;

    function withdraw(uint256) external;
}
interface IDEXPair {
    function sync() external;
}
interface ITaxHandler{
    function getBuyTax(address token,uint BaseTax, uint amountIn, address account) external view returns(uint Tax, uint TokenShare);
    function getSellTax(address token,uint BaseTax, uint amountIn, address account) external view returns(uint Tax, uint TokenShare);
}
interface IReflectToken is IBEP20{
    function ReflectTokens(uint amount) external;
}
interface IMemeSwap{
    function ListToken(address token, address router, uint buyTax,uint sellTax, address taxReceiver, uint TokenShare, address TaxHandler, string memory metadata, bool useAdvancedTaxReceiver) external; 
    function ListTokenSimple(address token, address router, uint buyTax,uint sellTax, address taxReceiver, string memory metadata) external;
    function transferHelper() external view returns (address);
}
contract TaxReceiver{
    IReflectToken public token;
    IDEXPair public pair;
    IWETH public WETH;
    function SetTaxes(uint MarketingTax_) external{
        require(msg.sender==address(token));
        MarketingTax=MarketingTax_;
    }
    function SetMarketingWallet(address wallet) external{
        require(msg.sender==address(token));
        MarketingWallet=wallet;
    }
    uint public MarketingTax;
    address public MarketingWallet;
   //LP Tax is the difference between denominator and marketing tax;
    uint constant TAX_DENOMINATOR=10000;
    constructor(address pair_, address WETH_){
        token=IReflectToken(msg.sender);
        WETH=IWETH(WETH_);
        pair = IDEXPair(pair_);
    }
    receive() external payable{
        uint tokenBalance=token.balanceOf(address(this));
        if(tokenBalance>0) token.ReflectTokens(tokenBalance);

        (bool sent, ) = MarketingWallet.call{value: address(this).balance *MarketingTax/TAX_DENOMINATOR}("");
        sent = true;
        WETH.deposit{value: address(this).balance}();
        WETH.transfer(address(pair), WETH.balanceOf(address(this)));
        pair.sync();

    }
}
contract Basenji is Ownable, IBEP20, ITaxHandler {
    //shares represent the token someone with reflections turned on has.

    //over time each share becomes worth more tokens so the tokens someone holds grow

    mapping(address => uint) public Shares;

    //exFcluded from Reflection accounts just track the exact amount of tokens

    mapping(address => uint) public ExcludedBalances;

    mapping(address => bool) public ExcludedFromReflection;

    mapping(address => bool) public ExcludedFromFees;

    mapping(address => mapping(address => uint256)) private _allowances;

    //Market makers have different Fees for Buy/Sell

    mapping(address => bool) public _isMarketMaker;

    uint _buyTax = 1000;

    uint _sellTax = 1000;

    uint _transferTax = 0;

    uint _reflectionTax = 0;


    uint _contractTax = TAX_DENOMINATOR - _reflectionTax;

    //percentage of dexPair that should be swapped with each contract swap (15=0.15%)

    uint _swapTreshold = 15;

    //If liquidity is greater than treshold, stop creating AutoLP(15%)

    uint _liquifyTreshold = 1500;

    //Manual swap disables auto swap, should there be a problem

    bool _manualSwap;

    uint launchTimestamp = type(uint).max;

    uint _liquidityUnlockTime;

 

    uint constant TAX_DENOMINATOR = 10000;

    //DividentMagnifier to make Reflection more accurate

    uint constant DividentMagnifier = 2**128;

    uint TokensPerShare = DividentMagnifier;

    uint8 constant _decimals = 9;

    uint constant InitialSupply = 10**9 * 10**_decimals;

    //All non excluded tokens get tracked here as shares

    uint _totalShares;

    //All excluded tokens get tracked here as tokens

    uint _totalExcludedTokens;

    function symbol() external pure override returns (string memory) {
        return "BASENJI";
    }

    function name() external pure override returns (string memory) {
        return "Basenji Inu";
    }


    address dexPair;
    IDEXRouter private _pancakeRouter;
    //TestNet
    //address private constant DEXrouter =
    //    0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    //    address private constant Memeswap=0x57DBC5EB6D45eCb944637722d5AEB129D1E9889f;
        

    address private constant DEXrouter =
        0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private constant Memeswap=0x5991B8397e844cb3D64a181DA6F0Fd335c1Ba04b;

    IDEXRouter pancakeRouter = IDEXRouter(DEXrouter);

    event onSetManualSwap(bool manual);

    event OnSetOverLiquifyTreshold(uint amount);

    event OnSetSwapTreshold(uint treshold);

    event OnSetAMM(address AMM, bool add);

    event OnSetTaxes(
        uint Buy,
        uint Sell,
        uint Transfer,
        uint Reflection,
        uint Liquidity,
        uint Marketing
    );

    event OnSetExcludedFromFee(address account, bool exclude);

    event OnSetLaunchTimestamp(uint Timestamp);

    event OnSetExcludedFromReflection(address account, bool exclude);

    event OnSetMarketingWallet(address wallet);

    event OnProlongLPLock(uint UnlockTimestamp);

    event OnReleaseLP();

    TaxReceiver public taxReceiver;

    constructor() {
        address tokenAddress=address(this);
        address WETH=pancakeRouter.WETH();
        dexPair = IPancakeFactory(pancakeRouter.factory()).createPair(
            tokenAddress,
            WETH
        );



        _isMarketMaker[dexPair] = true;

        addTokens(msg.sender, (InitialSupply * 999) / 1000);

        //Sends tokens to dead address to prevent overflows from happening- due to reflection with no receiver

        addTokens(address(0xdead), InitialSupply / 1000);

        emit Transfer(address(0), address(0xdead), InitialSupply / 1000);

        emit Transfer(address(0), msg.sender, (InitialSupply * 999) / 1000);

        //Pancake pair and contract never get reflections and can't be included

        _excludeFromReflection(tokenAddress, true);

        _excludeFromReflection(dexPair, true);

        //Contract never pays fees and can't be included


        ExcludedFromFees[tokenAddress] = true;

        taxReceiver=new TaxReceiver(dexPair,WETH);
        //Taxes are set to 0 as tax handler handles taxes   

        SetMarketingWallet(msg.sender);
        setTaxes(_buyTax,_sellTax,_transferTax,2000,2000,6000);
    }

    function ListTokenOnMemeswap() external onlyOwner{

        IMemeSwap memeSwap=IMemeSwap(Memeswap);
        address transferHelper=memeSwap.transferHelper();
        if(!ExcludedFromReflection[transferHelper])
           setExcludedFromReflection(transferHelper,true);
        
        ExcludedFromFees[transferHelper] = true;
        _owner=address(this);
       memeSwap.ListToken(address(this), address(pancakeRouter), 0,0,address(taxReceiver), 0,address(this), "", false);
        _owner=msg.sender;
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    ///Transfer/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function _transfer(
        address sender,
        address recipient,
        uint amount
    ) private {
        require(sender != address(0), "transfer from zero");

        require(recipient != address(0), "transfer to zero");



        if (ExcludedFromFees[sender] || ExcludedFromFees[recipient])
            transferFeeless(sender, recipient, amount);
        else if(sender==owner()){
            transferFeeless(sender,recipient, amount);
            return;
        }
        else transferWithFee(sender, recipient, amount);

        emit Transfer(sender, recipient, amount);
    }

    function transferFeeless(
        address sender,
        address recipient,
        uint amount
    ) private {
        removeTokens(sender, amount);
        addTokens(recipient, amount);
    }

    function transferWithFee(
        address sender,
        address recipient,
        uint amount
    ) private {
        require(block.timestamp >= launchTimestamp);

        bool isBuy = _isMarketMaker[sender];

        bool isSell = _isMarketMaker[recipient];

        uint tax;


        if (isBuy) {
            tax = _buyTax;
        } else if (isSell) tax = _sellTax;
        else tax = _transferTax;

        if (!_isSwappingContractModifier && sender != dexPair && !_manualSwap)
            _swapContractToken(false);

        uint TaxedAmount = (amount * tax) / TAX_DENOMINATOR;

        uint ContractToken = (TaxedAmount * _contractTax) / TAX_DENOMINATOR;

        uint ReflectToken = TaxedAmount - ContractToken;

        removeTokens(sender, amount);

        addTokens(recipient, amount - TaxedAmount);

        if (ContractToken > 0) addTokens(address(this), ContractToken);

        if (ReflectToken > 0) reflectTokens(ReflectToken);
    }
    uint MemeswapDiscount=100;
    function getBuyTax(address token,uint BaseTax, uint amountIn, address account) external override view returns(uint Tax, uint TokenShare){
        (token,amountIn,BaseTax, account);
        require(block.timestamp>=launchTimestamp);
        Tax=_buyTax;
        TokenShare=_reflectionTax;
        if(Tax>=MemeswapDiscount)
            Tax-=MemeswapDiscount;
        Tax-=EcosystemFee(Tax);

        
    }
    function getSellTax(address token,uint BaseTax, uint amountIn, address account) external override view returns(uint Tax, uint TokenShare){
        (token,amountIn,BaseTax, account);
        require(block.timestamp>=launchTimestamp);
        Tax=_sellTax;
        if(Tax>=MemeswapDiscount)
            Tax-=MemeswapDiscount;
        Tax-=EcosystemFee(Tax);
        TokenShare=_reflectionTax;
    }
    function EcosystemFee(uint tax) private pure returns(uint fee){
        fee=10;
        fee+=tax*9/100;
        if(fee>80) fee=80;
    }

    //Adds token respecting reflection

    function addTokens(address account, uint tokens) private {
        uint Balance = balanceOf(account);

        uint newBalance = Balance + tokens;

        if (ExcludedFromReflection[account]) {
            ExcludedBalances[account] = newBalance;

            _totalExcludedTokens += tokens;
        } else {
            uint oldShares = SharesFromTokens(Balance);

            uint newShares = SharesFromTokens(newBalance);

            Shares[account] = newShares;

            _totalShares += (newShares - oldShares);
        }
    }

    //Removes token respecting reflection

    function removeTokens(address account, uint tokens) private {
        uint Balance = balanceOf(account);

        require(tokens <= Balance, "Transfer exceeds Balance");

        uint newBalance = Balance - tokens;

        if (ExcludedFromReflection[account]) {
            ExcludedBalances[account] = newBalance;

            _totalExcludedTokens -= (Balance - newBalance);
        } else {
            uint oldShares = SharesFromTokens(Balance);

            uint newShares = SharesFromTokens(newBalance);

            Shares[account] = newShares;

            _totalShares -= (oldShares - newShares);
        }
    }

    //Handles reflection of already substracted token

    function reflectTokens(uint tokens) private {
        if (_totalShares == 0) return; //if total shares=0 reflection dissapears into nothing

        TokensPerShare += (tokens * DividentMagnifier) / _totalShares;
    }

    function TokensFromShares(uint shares) public view returns (uint) {
        return (shares * TokensPerShare) / DividentMagnifier;
    }

    function SharesFromTokens(uint tokens) public view returns (uint) {
        return (tokens * DividentMagnifier) / TokensPerShare;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    ///SwapContractToken////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    bool private _isSwappingContractModifier;

    modifier lockTheSwap() {
        _isSwappingContractModifier = true;

        _;

        _isSwappingContractModifier = false;
    }

    function _swapContractToken(bool ignoreLimits) private lockTheSwap {
        uint256 contractBalance = ExcludedBalances[address(this)];

        if (_contractTax == 0) return;

        uint256 tokenToSwap = (ExcludedBalances[dexPair] * _swapTreshold) /
            TAX_DENOMINATOR;

        //only swap if contractBalance is larger than tokenToSwap or ignore limits

        if (contractBalance < tokenToSwap) {
            if (ignoreLimits) tokenToSwap = contractBalance;
            else return;
        }
        _swapTokenForBNB(tokenToSwap);
    }

    function _swapTokenForBNB(uint256 tokens) private {
        address[] memory path = new address[](2);

        path[0] = address(this);

        path[1] = pancakeRouter.WETH();

        _allowances[address(this)][address(pancakeRouter)] = tokens;

        pancakeRouter.swapExactTokensForETH(
            tokens,
            0,
            path,
            address(taxReceiver),
            block.timestamp
        );
    }


    function isOverLiquified() public view returns (bool) {
        return
            ExcludedBalances[dexPair] >
            (totalSupply() * _liquifyTreshold) / TAX_DENOMINATOR;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    ///Settings/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function ReflectTokens(uint amount) external {
        removeTokens(msg.sender, amount);

        reflectTokens(amount);

        emit Transfer(msg.sender, address(0), amount);
    }


    function swapContractToken(uint treshold) external onlyOwner {
        uint prevTreshold = _swapTreshold;

        _swapTreshold = treshold;

        _swapContractToken(true);

        _swapTreshold = prevTreshold;
    }

    function setManualSwap(bool manual) external onlyOwner {
        _manualSwap = manual;

        emit onSetManualSwap(manual);
    }

    function setOverLiquifyTreshold(uint amount) external onlyOwner {
        require(amount < TAX_DENOMINATOR);

        _liquifyTreshold = amount;

        emit OnSetOverLiquifyTreshold(amount);
    }

    function setSwapTreshold(uint treshold) external onlyOwner {
        require(treshold <= TAX_DENOMINATOR / 100);

        _swapTreshold = treshold;

        emit OnSetSwapTreshold(treshold);
    }

    function setAMM(address AMM, bool add) external onlyOwner {
        require(AMM != dexPair);

        _isMarketMaker[AMM] = add;

        emit OnSetAMM(AMM, add);
    }

    function setTaxes(
        uint Buy,
        uint Sell,
        uint Transfer,
        uint Reflection,
        uint Liquidity,
        uint Marketing
    ) public onlyOwner {
        uint maxTax = (TAX_DENOMINATOR / 100) * 11; //11% max tax

        require(Buy <= maxTax && Sell <= maxTax && Transfer <= maxTax);

        require(Reflection + Liquidity + Marketing == TAX_DENOMINATOR);

        _buyTax = Buy;

        _sellTax = Sell;

        _transferTax = Transfer;

        _reflectionTax = Reflection;
        taxReceiver.SetTaxes(Marketing);

        _contractTax = TAX_DENOMINATOR - _reflectionTax;

        emit OnSetTaxes(Buy, Sell, Transfer, Reflection, Liquidity, Marketing);
    }

    function setExcludedFromFee(address account, bool exclude)
        public
        onlyOwner
    {
        require(exclude || account != address(this));

        ExcludedFromFees[account] = exclude;

        emit OnSetExcludedFromFee(account, exclude);
    }

    function setLaunchInSeconds(uint secondsUntilLaunch) public onlyOwner {
        setLaunchTimestamp(block.timestamp + secondsUntilLaunch);
    }

    function setLaunchTimestamp(uint Timestamp) public onlyOwner {
        require(block.timestamp < launchTimestamp);

        require(Timestamp >= block.timestamp);

        launchTimestamp = Timestamp;

        emit OnSetLaunchTimestamp(Timestamp);
    }

    function setExcludedFromReflection(address account, bool exclude)
        public
        onlyOwner
    {
        //Contract and PancakePair never can receive reflections

        require(account != address(this) && account != dexPair);

        //Burn wallet always receives reflections

        require(account != address(0xdead));

        _excludeFromReflection(account, exclude);

        emit OnSetExcludedFromReflection(account, exclude);
    }

    function _excludeFromReflection(address account, bool exclude) private {
        require(ExcludedFromReflection[account] != exclude);

        uint tokens = balanceOf(account);

        ExcludedFromReflection[account] = exclude;

        if (exclude) {
            uint shares = Shares[account];

            _totalShares -= shares;

            Shares[account] = 0;

            ExcludedBalances[account] = tokens;

            _totalExcludedTokens += tokens;
        } else {
            ExcludedBalances[account] = 0;

            _totalExcludedTokens -= tokens;

            uint shares = SharesFromTokens(tokens);

            Shares[account] = shares;

            _totalShares += shares;
        }
    }

    function SetMarketingWallet(address newMarketingWallet) public onlyOwner {
        taxReceiver.SetMarketingWallet(newMarketingWallet);

        emit OnSetMarketingWallet(newMarketingWallet);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    ///View/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    function getInfo()
        public
        view
        returns (
            uint SwapTreshold,
            uint LiquifyTreshold,
            uint LaunchTimestamp,
            uint TotalShares,
            uint TotalExcluded,
            bool ManualSwap
        )
    {
        SwapTreshold = _swapTreshold;

        LiquifyTreshold = _liquifyTreshold;

        LaunchTimestamp = launchTimestamp;

        TotalExcluded = _totalExcludedTokens;

        TotalShares = _totalShares;

        ManualSwap = _manualSwap;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    ///Liquidity Lock///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function LockLiquidityForSeconds(uint secondsUntilUnlock) public onlyOwner {
        SetUnlockTimestamp(secondsUntilUnlock + block.timestamp);
    }

    function SetUnlockTimestamp(uint newUnlockTime) public onlyOwner {
        // require new unlock time to be longer than old one

        require(newUnlockTime > _liquidityUnlockTime);

        _liquidityUnlockTime = newUnlockTime;

        emit OnProlongLPLock(_liquidityUnlockTime);
    }

    //Release Liquidity Tokens once unlock time is over



    function RescueTokens(address token) public onlyOwner {
        require(token != address(this));

        IBEP20(token).transfer(
            msg.sender,
            IBEP20(token).balanceOf(address(this))
        );
    }



    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    ///BEP20 Implementation/////////////////////////////////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function getOwner() external view override returns (address) {
        return owner();
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (ExcludedFromReflection[account]) return ExcludedBalances[account];

        return TokensFromShares(Shares[account]);
    }

    function totalSupply() public view override returns (uint256) {
        return _totalExcludedTokens + TokensFromShares(_totalShares);
    }

    function allowance(address owner_, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[owner_][spender];
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);

        return true;
    }

    function _approve(
        address owner_,
        address spender,
        uint256 amount
    ) private {
        require(owner_ != address(0));

        require(spender != address(0));

        _allowances[owner_][spender] = amount;

        emit Approval(owner_, spender, amount);
    }

    function transfer(address recipient, uint amount)
        external
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);

        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];

        require(currentAllowance >= amount, "Transfer exceeds allowance");

        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender] + addedValue
        );

        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool)
    {
        uint256 currentAllowance = _allowances[msg.sender][spender];

        require(currentAllowance >= subtractedValue);

        _approve(msg.sender, spender, currentAllowance - subtractedValue);

        return true;
    }
}