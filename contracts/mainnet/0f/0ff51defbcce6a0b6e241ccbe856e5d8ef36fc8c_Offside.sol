/**
 *Submitted for verification at BscScan.com on 2022-11-27
*/

//Telegram: https://t.me/OffsidePortal
//Web: https://offside.gg/
//Twitter: https://twitter.com/OffsideBSC/

// SPDX-License-Identifier: MIT

pragma solidity =0.8.17;

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
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

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



contract Offside is IERC20, Ownable
{
    mapping (address => uint) public balanceOf;
    mapping (address => mapping (address => uint)) private _allowances;
    mapping(address => bool) public excludedFromFees;
    mapping(address=>bool) public isAMM;
    //Token Info
    string public constant name = 'Offside';
    string public constant symbol = 'Offside';
    uint8 public constant decimals = 18;
    uint public constant totalSupply = 100_000_000 * 10**decimals;

    //TestNet
    //address private constant PancakeRouter=0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    //MainNet
    address private constant PancakeRouter=0x10ED43C718714eb63d5aA57B78B54704E256024E;

    event OnSetAMM(address pair, bool add);
    event OnSetManualSwapback(bool on);
    event OnManualSwapBack();
    event OnSetLaunchTimestamp(uint timestamp);
    event ExcludeAccount(address account, bool exclude);
    event OnChangeMarketingWallet(address newWallet);
    event OnChangeRewardsWallet(address newWallet);
    event OnChangeLiquidityWallet(address newWallet);
    event OnChangeMultisigWallet(address newWallet);
    event OnSetTaxes(uint buy, uint sell, uint transfer_, uint marketing,uint liquidity, uint rewards);
    event OnSetSwapWholeStorage(bool flag);


    uint public buyTax = 50;
    uint public sellTax = 50;
    uint public transferTax = 0;
    uint constant TAX_DENOMINATOR=1000;
    uint constant MAXTAX=200;//Combined for buy and sell

    uint public liquidityShare=1;
    uint public marketingShare=1;
    uint public rewardsShare=3;
    uint private shareDenominator=5;

    uint public LaunchTimestamp=type(uint).max;

    address private pair; 
    IPancakeRouter private  router;
    
    address public marketingWallet;
    address public rewardsWallet;
    address public liquidityWallet;
    address public multisigWallet;

    uint public swapBackTreshold=2;
    bool public swapWholeStorage=true;

    //modifier for functions only the team can call
    modifier onlyTeam() {
        require(_isTeam(msg.sender), "Caller not Team or Owner");
        _;
    }
    modifier onlyMultisig(){
        require(msg.sender==multisigWallet,"Only multisig can call this");
        _;
    }
    function _isTeam(address addr) private view returns (bool){
        return addr==owner()||addr==marketingWallet||addr==rewardsWallet||addr==liquidityWallet||addr==multisigWallet;
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Constructor///////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    constructor () {
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);

        // Pancake Router
        router = IPancakeRouter(PancakeRouter);
        //Creates a Pancake Pair
        pair = IPancakeFactory(router.factory()).createPair(address(this), router.WETH());
        isAMM[pair]=true;
        
        //contract creator is by default marketing wallet
        marketingWallet=msg.sender;
        rewardsWallet=msg.sender;
        liquidityWallet=msg.sender;
        multisigWallet=msg.sender;

        excludedFromFees[msg.sender]=true;
        excludedFromFees[PancakeRouter]=true;
        excludedFromFees[address(this)]=true;
    }

    function _transfer(address sender, address recipient, uint amount) private{
        require(sender != address(0), "Transfer from zero");
        require(recipient != address(0), "Transfer to zero");


        //Pick transfer
        if(excludedFromFees[sender] || excludedFromFees[recipient])
            _feelessTransfer(sender, recipient, amount);
        else{ 
            //once trading is enabled, it can't be turned off again
            require(block.timestamp>=LaunchTimestamp,"trading not yet enabled");
            _taxedTransfer(sender,recipient,amount);                  
        }
    }
    //applies taxes, checks for limits, locks generates autoLP and stakingBNB, and autostakes
    function _taxedTransfer(address sender, address recipient, uint amount) private{
        uint senderBalance = balanceOf[sender];
        require(senderBalance >= amount, "Transfer exceeds balance");

        bool isBuy=isAMM[sender];
        bool isSell=isAMM[recipient];

        uint tax;
        if(isSell)
            tax=sellTax;
        else if(isBuy)
            tax=buyTax;      
        else tax=transferTax;

        if((sender!=pair)&&(!manualSwap)&&(!_inSwap))
            _swapContractToken();

        uint feeAmount=amount*tax/TAX_DENOMINATOR;
        uint taxedAmount=amount-feeAmount;

        balanceOf[sender]-=amount;
        //Adds the taxed tokens to the contract wallet
        balanceOf[address(this)] += feeAmount;
        emit Transfer(sender, address(this), feeAmount);

        balanceOf[recipient]+=taxedAmount;
        emit Transfer(sender,recipient,taxedAmount);
    }

    //Feeless transfer only transfers and autostakes
    function _feelessTransfer(address sender, address recipient, uint amount) private{
        uint senderBalance = balanceOf[sender];
        require(senderBalance >= amount, "Transfer exceeds balance");
        balanceOf[sender]-=amount;
        balanceOf[recipient]+=amount;      
        emit Transfer(sender,recipient,amount);
    }
    //Locks the swap if already swapping
    bool private _inSwap;
    modifier lockTheSwap {
        _inSwap = true;
        _;
        _inSwap = false;
    }

    //Sets the permille of pancake pair to trigger liquifying taxed token
 
    function setSwapTreshold(uint newSwapTreshold) public onlyTeam{
        require(newSwapTreshold<=50);//MaxTreshold= 5%
        swapBackTreshold=newSwapTreshold;
    }
    //Sets the max Liquidity where swaps for Liquidity still happen
    uint public overLiquifyTreshold=150;//15% liquidity target
    event OnSetOverLiquifyTreshold(uint treshold);
    function SetOverLiquifiedTreshold(uint newOverLiquifyTreshold) public onlyTeam{
        require(newOverLiquifyTreshold<=1000);
        overLiquifyTreshold=newOverLiquifyTreshold;
        emit OnSetOverLiquifyTreshold(overLiquifyTreshold);
    }


    function SetTaxes(uint buy, uint sell, uint transfer_, uint marketing,uint liquidity, uint rewards) external onlyTeam{
        require(buy+sell<=MAXTAX&&transfer_<=MAXTAX/2,"Tax exceeds maxTax");
        shareDenominator=marketing+liquidity+rewards;
        require(shareDenominator>0);
        buyTax=buy;
        sellTax=sell;
        transferTax=transfer_;

        marketingShare=marketing;
        rewardsShare=rewards;
        liquidityShare=liquidity;
        emit OnSetTaxes(buy, sell, transfer_, marketing,liquidity,rewards);
    }
    
    //If liquidity is over the treshold, convert 100% of Token to Marketing BNB to avoid overliquifying
    function isOverLiquified() public view returns(bool){
        return balanceOf[pair]>totalSupply*overLiquifyTreshold/1000;
    }

    function setSwapWholeStorage(bool flag) external onlyTeam{
        swapWholeStorage=flag;
        emit OnSetSwapWholeStorage(flag);
    }

    function _swapContractToken() private lockTheSwap{
        uint contractBalance=balanceOf[address(this)];
        //swaps each time it reaches swapBackTreshold of pancake pair to avoid large prize impact
        uint tokenToSwap=balanceOf[pair]*swapBackTreshold/TAX_DENOMINATOR;

        //only swap if contractBalance is larger than tokenToSwap, and totalTax is unequal to 0
        //Ignore limits swaps 100% of the contractBalance
        if(contractBalance<tokenToSwap)
            return;
        if(swapWholeStorage)
            tokenToSwap=contractBalance;

        //splits the token in TokenForLiquidity and tokenForBNB
        //if over liquified, 0 tokenForLiquidity
        uint tokenForLiquidity=
        isOverLiquified()?0
        :(tokenToSwap*liquidityShare)/shareDenominator;

        uint tokenForBNB= tokenToSwap-tokenForLiquidity;

        uint LiqHalf=tokenForLiquidity/2;
        //swaps marktetingToken and the liquidity token half for BNB
        uint swapToken=LiqHalf+tokenForBNB;
        if(swapToken==0) return;
        //Gets the initial BNB balance, so swap won't touch any contract BNB
        uint initialBNBBalance = address(this).balance;
        _swapTokenForBNB(swapToken);
        uint newBNB=(address(this).balance - initialBNBBalance);

        //calculates the amount of BNB belonging to the LP-Pair and converts them to LP
        if(tokenForLiquidity>0){
            uint liqBNB = (newBNB*LiqHalf)/swapToken;
            _addLiquidity(LiqHalf, liqBNB);
        }
        //Sends all the marketing BNB to the marketingWallet
        uint bnbShare=marketingShare+rewardsShare;
        bool sent;
        if(bnbShare>0)
            (sent,)=marketingWallet.call{value:address(this).balance*marketingShare/bnbShare}("");
        (sent,)=rewardsWallet.call{value:address(this).balance}("");
    }
    //swaps tokens on the contract for BNB
    function _swapTokenForBNB(uint amount) private {
        _approve(address(this), address(router), amount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        try router.swapExactTokensForETHSupportingFeeOnTransferTokens(
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
        _approve(address(this), address(router), tokenamount);
        router.addLiquidityETH{value: bnbamount}(
            address(this),
            tokenamount,
            0,
            0,
            liquidityWallet,
            block.timestamp
        );
    }

    function SetAMM(address AMM, bool Add) public onlyTeam{
        require(AMM!=pair,"can't change pancake");
        isAMM[AMM]=Add;
        emit OnSetAMM(AMM,Add);
    }
    bool public manualSwap;
    function SwitchManualSwap(bool manual) public onlyTeam{
        manualSwap=manual;
        emit OnSetManualSwapback(manual);
    }
    function ManualSwapBack() public onlyTeam{
        bool prev=swapWholeStorage;
        swapWholeStorage=true;
        _swapContractToken();
        swapWholeStorage=prev;
        emit OnManualSwapBack();
    }

    function ExcludeAccountFromFees(address account, bool exclude) external onlyTeam{
        require(account!=address(this),"can't Include the contract");
        excludedFromFees[account]=exclude;
        emit ExcludeAccount(account,exclude);
    }

    //Enables trading for everyone, cant be changed once it's live
    function Launch(uint delaySeconds) external{
        SetLaunchTimestamp(block.timestamp+delaySeconds);
    }
    function SetLaunchTimestamp(uint Timestamp) public onlyTeam{
        require(LaunchTimestamp>block.timestamp,"already Launched");
        LaunchTimestamp=Timestamp;
        emit OnSetLaunchTimestamp(Timestamp);
    }
    function ChangeMarketingWallet(address newWallet) external onlyMultisig{
        marketingWallet=newWallet;
        emit OnChangeMarketingWallet(newWallet);
    }
    function ChangeRewardsWallet(address newWallet) external onlyMultisig{
        rewardsWallet=newWallet;
        emit OnChangeRewardsWallet(newWallet);
    }
    function ChangeLiquidityWallet(address newWallet) external onlyMultisig{
        liquidityWallet=newWallet;
        emit OnChangeLiquidityWallet(newWallet);
    }
    function ChangeMultisigWallet(address newWallet) external onlyMultisig{
        multisigWallet=newWallet;
        emit OnChangeMultisigWallet(newWallet);
    }

    receive() external payable {
        require(_inSwap);
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