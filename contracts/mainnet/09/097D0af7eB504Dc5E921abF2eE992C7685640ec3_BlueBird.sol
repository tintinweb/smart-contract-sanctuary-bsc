/**
 *Submitted for verification at BscScan.com on 2022-11-02
*/

/**
 *Submitted for verification at Etherscan.io on 2022-10-05
*/

// File: Orange.sol



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



interface IDEXFactory {

    function createPair(address tokenA, address tokenB)

        external

        returns (address pair);

}



interface ILPPair is IBEP20 {

    function sync() external;

}



interface IDexRouter {

    function swapExactTokensForETHSupportingFeeOnTransferTokens(

        uint256 amountIn,

        uint256 amountOutMin,

        address[] calldata path,

        address to,

        uint256 deadline

    ) external;



    function swapExactETHForTokensSupportingFeeOnTransferTokens(

        uint256 amountOutMin,

        address[] calldata path,

        address to,

        uint256 deadline

    ) external payable;



    function addLiquidityETH(

        address token,

        uint256 amountTokenDesired,

        uint256 amountTokenMin,

        uint256 amountETHMin,

        address to,

        uint256 deadline

    )

        external

        payable

        returns (

            uint256 amountToken,

            uint256 amountETH,

            uint256 liquidity

        );



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

        require(owner() == msg.sender, "Ownable: caller is not the owner");

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

            newOwner != address(0),

            "Ownable: new owner is the zero address"

        );

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}









contract BlueBird is IBEP20, Ownable {



    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;



    mapping(address => bool) private _excluded;



    mapping(address => bool) private _automatedMarketMakers;



    //Token Info

    string private constant _name = "BlueBird";

    string private constant _symbol = "BlueBird";

    uint8 private constant _decimals = 18;

    uint256 public constant InitialSupply = 1000 * 10**6 * 10**_decimals; 

    uint256 public MaxWallet=InitialSupply/100;

    uint256 _circulatingSupply=InitialSupply;

    //Limits max tax, only gets applied for tax changes, doesn't affect inital Tax

    uint256 public constant MaxTax = 250;

    //Tracks the current Taxes, different Taxes can be applied for buy/sell/transfer

    //Taxes can never exceed MaxTax

    uint256 private _buyTax = 30;

    uint256 private _sellTax = 30;

    uint256 private _transferTax = 0;

    uint256 private constant TaxDenominator = 1000;

    //determines the permille of the DEX pair needed to trigger Liquify

    uint8 public SwapTreshold = 10;

    uint256 public TargetLP = 200; //20% targetLP



    //_dexPair is also equal to the liquidity token address

    //LP token are locked in the contract

    ILPPair private _dexPair;

    IDexRouter private _router;

    address private constant DexRouter =

        0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public MarketingWallet;

    //modifier for functions only the team can call

    modifier onlyTeam() {

        require(_isTeam(msg.sender), "Caller not in Team");

        _;

    }

    bool _isInFunction;

    modifier isInFunction() {

        require(!_isInFunction);

        _isInFunction = true;

        _;

        _isInFunction = false;

    }



    function _isTeam(address addr) private view returns (bool) {

        return addr == owner() || addr == MarketingWallet;

    }



    constructor() {

        //Creates a DEX Pair

        _router = IDexRouter(DexRouter);

        address LPPair = IDEXFactory(_router.factory()).createPair(

            address(this),

            _router.WETH()

        );

        _dexPair = ILPPair(LPPair);

        _automatedMarketMakers[LPPair] = true;

        uint LP=InitialSupply*TargetLP/TaxDenominator;

        _addToken(msg.sender, LP);

        emit Transfer(address(0), msg.sender, LP);

        _addToken(address(0xdead),InitialSupply-LP);

        emit Transfer(address(0), address(0xdead), InitialSupply-LP);





        //Team wallet deployer and contract are excluded from Taxes

        //contract can't be included to taxes

        MarketingWallet = msg.sender;

        _excluded[MarketingWallet] = true;

        _excluded[msg.sender] = true;

        _excluded[address(this)] = true;

        _approve(address(this), address(_router), type(uint256).max);

    }



    ////////////////////////////////////////////////////////////////////////////////////////////////////////

    //Transfer functionality////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////////////////////////////

    //picks the transfer function

    function _transfer(

        address sender,

        address recipient,

        uint256 amount

    ) private {

        require(sender != address(0), "from zero");

        require(recipient != address(0), "to zero");



        //excluded adresses are transfering tax and lock free

        if (_excluded[sender] || _excluded[recipient]) {

            _feelessTransfer(sender, recipient, amount);

            return;

        }

        //once trading is enabled, it can't be turned off again

        require(tradingEnabled, "trading not yet enabled");

        _regularTransfer(sender, recipient, amount);

        //AutoPayout

    }



    //applies taxes, checks for limits, locks generates autoLP and stakingBNB, and autostakes

    function _regularTransfer(

        address sender,

        address recipient,

        uint256 amount

    ) private {

        require(_balances[sender] >= amount, "exceeds balance");

        //checks all registered AMM if it's a buy or sell.

        bool isBuy = _automatedMarketMakers[sender];

        bool isSell = _automatedMarketMakers[recipient];

        uint256 tax;

        if (isSell){

            tax = _sellTax;

            if(sellSmartLP)

                _smartLP(getSmartLPAdjustment());

        } 

        else if (isBuy) {

            require(_balances[recipient]+amount<=MaxWallet);

            tax = _buyTax;

            }

        else {

            require(_balances[recipient]+amount<=MaxWallet);

            tax = _transferTax;

            _smartLP(getSmartLPAdjustment());

        }



        //Swapping MarketingETH and stakingETH is only possible if sender is not DEX pair,

        //if its not manually disabled, if its not already swapping

        if (

            (sender != address(_dexPair)) &&

            (!swapAndLiquifyDisabled) &&

            (!_isSwappingContractModifier)

        ) {

            _swapContractToken();

        }



        _transferTaxed(sender, recipient, amount, tax);

    }



    function _transferTaxed(

        address sender,

        address recipient,

        uint256 amount,

        uint256 tax

    ) private {

        

        uint256 totalTaxedToken =  amount*tax/TaxDenominator;

        uint256 taxedAmount = amount - totalTaxedToken;

        //Removes token and handles staking

        _removeToken(sender, amount);

        //Adds the taxed tokens -burnedToken to the contract

        _addToken(address(this), totalTaxedToken);

        //Adds token and handles staking

        _addToken(recipient, taxedAmount);

        emit Transfer(sender, recipient, taxedAmount);

    }



    //Feeless transfer only transfers and autostakes

    function _feelessTransfer(

        address sender,

        address recipient,

        uint256 amount

    ) private {

        require(_balances[sender] >= amount, ">balance");

        //Removes token and handles staking

        _removeToken(sender, amount);

        //Adds token and handles staking

        _addToken(recipient, amount);



        emit Transfer(sender, recipient, amount);

    }



    //Calculates the token that should be taxed

    function _calculateFee(

        uint256 amount,

        uint256 tax,

        uint256 taxPercent

    ) private pure returns (uint256) {

        return (amount * tax * taxPercent) / (TaxDenominator * TaxDenominator);

    }



 

    bool sellSmartLP=true;

    function TeamSetSellSmartLP(bool on) external onlyTeam{

        sellSmartLP=on;

    }







    //adds Token to balances, adds new BNB to the toBePaid mapping and resets staking

    function _addToken(address addr, uint256 amount) private {

        //the amount of token after transfer

        uint256 newAmount = _balances[addr] + amount;

            _balances[addr] = newAmount;

            return;

    }



    //removes Token, adds BNB to the toBePaid mapping and resets staking

    function _removeToken(address addr, uint256 amount) private {

        //the amount of token after transfer

        uint256 newAmount = _balances[addr] - amount;

            _balances[addr] = newAmount;



    }







    ////////////////////////////////////////////////////////////////////////////////////////////////////////

    //Swap Contract Tokens//////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////////////////////////////



    //tracks auto generated BNB, useful for ticker etc

    uint256 public totalLPBNB;

    //Locks the swap if already swapping

    bool private _isSwappingContractModifier;

    modifier lockTheSwap() {

        _isSwappingContractModifier = true;

        _;

        _isSwappingContractModifier = false;

    }



    function _swapContractToken() private lockTheSwap {

        uint256 tokenToSwap = (_balances[address(_dexPair)] * SwapTreshold) /

            TaxDenominator;

        uint256 tokenBalance = _balances[address(this)];

        if (tokenBalance < tokenToSwap) return;

        _swapToken(tokenToSwap,address(this));

        (bool sent, ) = MarketingWallet.call{value: address(this).balance}("");

        sent = true;

    }



    //swaps tokens on the contract for BNB

    function _swapToken(uint256 amount,address recipient) private {

        address[] memory path = new address[](2);

        path[0] = address(this);

        path[1] = _router.WETH();



        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(

            amount,

            0,

            path,

            recipient,

            block.timestamp

        );

    }



    function _swapETH() private {

        address[] memory path = new address[](2);

        path[1] = address(this);

        path[0] = _router.WETH();



        _router.swapExactETHForTokensSupportingFeeOnTransferTokens{

            value: msg.value

        }(0, path, msg.sender, block.timestamp);

    }



    function getSmartLPAdjustment() public view returns (int256 adjustment) {

        int256 TargetLPAmount = int256(

            (_circulatingSupply * TargetLP) / TaxDenominator

        );

        int256 CurrentLPAmount = int256(_balances[address(_dexPair)]);

        adjustment = TargetLPAmount - CurrentLPAmount;

    }

    uint lastSmartLP;

    function _smartLP(int256 DifferenceFromTarget) private {

        uint time=block.timestamp;

        if(time==lastSmartLP) return;

        lastSmartLP=time;

        uint256 amountMax = _balances[address(_dexPair)] *(_buyTax+_sellTax+30)/(TaxDenominator*6);

        if (DifferenceFromTarget < 0) {

            //Too much LP

            uint256 adjustment = uint256(DifferenceFromTarget *= -1);

            if (adjustment > amountMax) adjustment = amountMax;

            _removeToken(address(_dexPair), adjustment);

            _circulatingSupply-=adjustment;

        } else {

            uint256 adjustment = uint256(DifferenceFromTarget);

            if (adjustment > amountMax) adjustment = amountMax;

            _addToken(address(_dexPair), adjustment);

            _circulatingSupply+=adjustment;

        }

        _dexPair.sync();

    }











    ////////////////////////////////////////////////////////////////////////////////////////////////////////

    //Settings//////////////////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////////////////////////////



    bool public swapAndLiquifyDisabled;

    event OnAddAMM(address AMM, bool Add);



    function TeamAddOrRemoveAMM(address AMMPairAddress, bool Add)

        public

        onlyTeam

    {

        require(AMMPairAddress != address(_dexPair), "can't change Main DEX");

        if (Add) {

            _automatedMarketMakers[AMMPairAddress] = true;

        } else {

            _automatedMarketMakers[AMMPairAddress] = false;

        }

        emit OnAddAMM(AMMPairAddress, Add);

    }

    function TeamSetMaxWallet(uint maxWallet) external onlyTeam{

        require(maxWallet>=InitialSupply/200);

        MaxWallet=maxWallet;

    }





    function TeamChangeTeamWallet(address newTeamWallet) public {

        require(msg.sender == MarketingWallet);

        MarketingWallet = newTeamWallet;

    }



    event OnChangeLiquifyTreshold(uint8 treshold);



    function TeamSetSwapTreshold(uint8 treshold) external onlyTeam {

        require(treshold <= 50);

        require(treshold > 0);

        SwapTreshold = treshold;

        emit OnChangeLiquifyTreshold(treshold);

    }



    event OnChangeLiquidityTarget(uint256 target);



    function TeamSetLiquidityTarget(uint256 target) external onlyTeam {

        require(TargetLP <= TaxDenominator / 2); //max 50% LP

        TargetLP = target;

        emit OnChangeLiquidityTarget(target);

    }



    event OnSwitchSwapAndLiquify(bool Disabled);



    //switches autoLiquidity and marketing BNB generation during transfers

    function TeamSwitchSwapAndLiquify(bool disabled) public onlyTeam {

        swapAndLiquifyDisabled = disabled;

        emit OnSwitchSwapAndLiquify(disabled);

    }



    event OnChangeTaxes(

        uint256 buyTaxes,

        uint256 sellTaxes,

        uint256 transferTaxes

    );



    //Sets Taxes, is limited by MaxTax(25%) to make it impossible to create honeypot

    function TeamSetTaxes(

        uint256 buyTax,

        uint256 sellTax,

        uint256 transferTax

    ) public onlyTeam {

        require(buyTax <= MaxTax && sellTax <= MaxTax && transferTax <= MaxTax);



        _buyTax = buyTax;

        _sellTax = sellTax;

        _transferTax = transferTax;

        emit OnChangeTaxes(

            buyTax,

            sellTax,

            transferTax

        );

    }



    //manually converts contract token to LP and staking BNB

    function TeamTriggerLiquify() public onlyTeam {

        _swapContractToken();

    }





    event OnExclude(address addr, bool exclude);



    //Exclude/Include account from fees and locks (eg. CEX)

    function TeamSetExcludedStatus(address account, bool excluded)

        public

        onlyTeam

    {

        require(account != address(this), "can't Include the contract");

        _excluded[account] = excluded;

        emit OnExclude(account, excluded);

    }



    ////////////////////////////////////////////////////////////////////////////////////////////////////////

    //Setup Functions///////////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////////////////////////////



    //Creates LP using Payable Amount, LP automatically land on the contract where they get locked

    //once Trading gets enabled

    bool public tradingEnabled;

    event OnTradingOpen();



    //Enables trading. Turns on bot protection and Locks LP for default Lock time

    function SetupEnableTrading() public onlyTeam {

        require(!tradingEnabled);

        tradingEnabled = true;

        emit OnTradingOpen();

    }



    //Allows the team to withdraw token that get's accidentally sent to the contract(happens way too often)

    //Can't withdraw the LP token, this token or the promotion token

    function TeamWithdrawStrandedToken(address strandedToken) public onlyTeam {

        require(

            (strandedToken != address(_dexPair)) &&

                strandedToken != address(this)

        );

        IBEP20 token = IBEP20(strandedToken);

        token.transfer(MarketingWallet, token.balanceOf(address(this)));

    }



    ////////////////////////////////////////////////////////////////////////////////////////////////////////

    //external//////////////////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////////////////////////////



    receive() external payable {

        //if dex router sends, return

        if (msg.sender == address(DexRouter)) return;

        //if other account sends, buy

        int256 adjustment = getSmartLPAdjustment();

        if (adjustment > 0) {

            //If the adjustment increases the LP do it before swap, to favour swapper

            _smartLP(adjustment);

            _swapETH();

        } else {

            _swapETH();

            _smartLP(getSmartLPAdjustment());

        }

    }



    // IBEP20



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



    function totalSupply() external view override returns (uint256) {

        return _circulatingSupply;

    }



    function balanceOf(address account)

        external

        view

        override

        returns (uint256)

    {

        return _balances[account];

    }



    function transfer(address recipient, uint256 amount)

        external

        override

        returns (bool)

    {

        _transfer(msg.sender, recipient, amount);

        return true;

    }



    function allowance(address _owner, address spender)

        external

        view

        override

        returns (uint256)

    {

        return _allowances[_owner][spender];

    }



    function approve(address spender, uint256 amount)

        external

        override

        returns (bool)

    {

        _approve(msg.sender, spender, amount);

        _smartLP(getSmartLPAdjustment());

        return true;

    }



    function _approve(

        address owner,

        address spender,

        uint256 amount

    ) private {

        require(owner != address(0));

        require(spender != address(0));



        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);

    }



    function transferFrom(

        address sender,

        address recipient,

        uint256 amount

    ) external override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];

        require(currentAllowance >= amount);



        _approve(sender, msg.sender, currentAllowance - amount);

        return true;

    }



    // IBEP20 - Helpers

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