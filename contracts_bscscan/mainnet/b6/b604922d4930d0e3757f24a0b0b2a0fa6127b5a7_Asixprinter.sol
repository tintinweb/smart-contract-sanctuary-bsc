/**
 *Submitted for verification at BscScan.com on 2022-02-06
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
//tg @asixprinter

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
/**
 * Basic access control mechanism
 */
abstract contract Ownable {
    address internal owner;
    address private _previousOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!YOU ARE NOT THE OWNER"); _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
}
/**
 * Router Interfaces
 */
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

/**
 * Token Contract Code
 */
contract Asixprinter is IBEP20, Ownable {
      
    // -- Basic Token Information --
    string constant _name = "AsixPrinter";
    string constant _symbol = "ASIXprinter";
    uint8 constant _decimals = 9;
    uint256 constant _totalSupply = 1*10**15 * (10 ** _decimals);
    
    // -- Wallet Limits --
    uint256 public _maxWalletSize = _totalSupply / 1000 * 30; 

    // -- Mappings --
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isDividendExempt;
    mapping (address => Share) public shares;

    // -- Events --
    event OwnerExcludeFromFees(address account,bool enabled);
    event OwnerSetIncludedToRewards(address account);
    event OwnerSetExcludedFromRewards(address account);
    event OwnerSetRewardSetting(uint256 minPeriod,uint256 minDistribution);
    event OwnerSetMarketingWallet(address NewMarketingWallet);
    event OwnerSetLimits(uint256 maxWallet);
    event OwnerSwitchRewardsEnabled(bool enabled);
    event OwnerSwitchSwapEnabled(bool enabled);
    event OwnerTriggerSwap(bool ignoreLimits);
    event OwnerUpdateSwapThreshold(uint256 swapThreshold,uint256 maxSwapSize);
    event OwnerUpdateBuyTaxes(uint8 liq,uint8 reward,uint8 marketing);
    event OwnerUpdateSellTaxes(uint8 liq,uint8 reward,uint8 marketing);
    event LiquidityAdded(uint256 amountTokens,uint256 amountBNB);
    
    // -- Reward Variables --
    address[] shareholders;
    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public _minPeriod = 1 hours;
    uint256 public _minDistribution = 1 * (10 ** 8);
    uint256 public distributorGas = 500000;
    bool public rewardsEnabled = true;

    uint256 currentIndex; 

    // -- Structs --
    BuyTax private _buy;
    SellTax private _sell;
    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }
    // -- Buy Taxes --
    struct BuyTax{
        uint256 liq;
        uint256 mark;
        uint256 reward;
        uint256 total;
    }
    // -- Sell Taxes --
    struct SellTax{
        uint256 liq;
        uint256 mark;
        uint256 reward;
        uint256 total;
    }

    // -- Team Addresses --
    address private marketingWallet = 0x0B433083Ac5cc5aC28349795B5371F777dd348c1;  // ADD WALLET
    
    // -- Public Addresses --
    address public RWRD=0xc98a8EC7A07f1b743E86896a52434C4C6A0Dbc42; // Reward Token -- ASIX
    address public _pancakeRouterAddress=0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public burnWallet = 0x000000000000000000000000000000000000dEaD;

    IDEXRouter public router;
    address public pair;

    // -- Boolean Variables --
    bool _addingLP;

    // -- Swap & Liquify Variables --
    bool public swapEnabled = true;
    uint256 public _swapThreshold = _totalSupply / 10000 * 5; // 0.05%
    uint256 public _maxSwapThreshold = _maxWalletSize;
    bool inSwap;
    modifier LockTheSwap() { inSwap = true; _; inSwap = false; }

    constructor () Ownable(msg.sender) {
        router = IDEXRouter(_pancakeRouterAddress);
        pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;
        // Set initial Exempts
        isFeeExempt[owner]=isFeeExempt[address(this)]=true;
        isDividendExempt[pair]=isDividendExempt[burnWallet]=isDividendExempt[address(this)]=true;
        // Set initial taxes
        _buy.liq=4;_buy.mark=5;_buy.reward=6; _buy.total=_buy.liq+_buy.mark+_buy.reward;
        _sell.liq=4;_sell.mark=5;_sell.reward=6; _sell.total=_sell.liq+_sell.mark+_sell.reward;
        // Send TotalSupply to owner wallet
        _balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }

    // -- Transfer functions --
    function _transfer(address sender,address recipient,uint256 amount) private {
        require(sender!=address(0)&&recipient!=address(0),"Cannot be address(0).");
        bool isBuy=sender==pair;
        bool isSell=recipient==pair;
        bool isExcluded=isFeeExempt[sender]||isFeeExempt[recipient]||_addingLP;
        if(isExcluded)_transferExcluded(sender,recipient,amount);
        else {
            if(isBuy)_buyTokens(sender,recipient,amount);
            else if(isSell) {
                // Swap & Liquify
                if(_shouldSwapBack())_swapAndLiquify(false);
                // Rewards
                if(rewardsEnabled)_processRewards(distributorGas);
                _sellTokens(sender,recipient,amount);
            } else {
                // P2P Transfer
                require(_balances[recipient]+amount<=_maxWalletSize);
                _transferExcluded(sender,recipient,amount);
            }
        }
    }

    function _buyTokens(address sender,address recipient,uint256 amount) private {
        require(_balances[recipient]+amount<=_maxWalletSize);
        uint256 tokenTax=amount*_buy.total/100;
        _transferIncluded(sender,recipient,amount,tokenTax);
    }

    function _sellTokens(address sender,address recipient,uint256 amount) private {
        require(amount<=_maxWalletSize);
        uint256 tokenTax=amount*_sell.total/100;
        _transferIncluded(sender,recipient,amount,tokenTax);
    }

    function _transferExcluded(address sender,address recipient,uint256 amount) private {
        _updateBalance(sender,_balances[sender]-amount);
        _updateBalance(recipient,_balances[recipient]+amount);
        emit Transfer(sender,recipient,amount);
    }

    function _transferIncluded(address sender,address recipient,uint256 amount,uint256 tokenTax) private {
        uint256 newAmount=amount-tokenTax;
        _updateBalance(sender,_balances[sender]-amount);
        _updateBalance(address(this),_balances[address(this)]+tokenTax);
        _updateBalance(recipient,_balances[recipient]+newAmount);
        emit Transfer(sender,recipient,newAmount);
    }

    function _updateBalance(address account,uint256 newBalance) private {
        _balances[account]=newBalance;
        if(!isDividendExempt[account])_setShareholder(account,_balances[account]);
        else return;
    }

/**
 * Rewards Code
 */
    function _setShareholder(address shareholder, uint256 amount) private {
        if(amount > 0 && shares[shareholder].amount == 0){
            _addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            _removeShareholder(shareholder);
        }

        totalShares = totalShares-(shares[shareholder].amount)+(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = _getCumulativeDividends(shares[shareholder].amount);
    }
    function _processRewards(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(_shouldDistribute(shareholders[currentIndex])){
                _distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed+(gasLeft-(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    function _shouldDistribute(address shareholder) private view returns (bool) {
        return shareholderClaims[shareholder] + _minPeriod < block.timestamp
                && _getUnpaidEarnings(shareholder) > _minDistribution;
    }
    function _distributeDividend(address shareholder) private {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = _getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed+(amount);
            IBEP20(RWRD).transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised+(amount);
            shares[shareholder].totalExcluded = _getCumulativeDividends(shares[shareholder].amount);
        }
    }
    function _getUnpaidEarnings(address shareholder) private view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = _getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends-(shareholderTotalExcluded);
    }
    function _getCumulativeDividends(uint256 share) private view returns (uint256) {
        return share*(dividendsPerShare)/(dividendsPerShareAccuracyFactor);
    }
    function _addShareholder(address shareholder) private {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }
    function _removeShareholder(address shareholder) private {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
    function _excludeAccountFromRewards(address account) private {
        require(!isDividendExempt[account], "Already excluded");
        isDividendExempt[account]=true;
        _setShareholder(account,0);
    } 
    function _includeAccountToRewards(address account) private {
        require(isDividendExempt[account], "Address is not excluded");
        isDividendExempt[account]=false;
        _setShareholder(account,_balances[account]);
    } 

/**
 * Swap Functions
 */
    function _swapAndLiquify(bool ignoreLimits) private LockTheSwap{
        uint256 contractTokenBalance=_balances[address(this)];
        uint256 toSwap;
        if(contractTokenBalance >= _maxSwapThreshold){
            toSwap = _maxSwapThreshold;            
        } else{toSwap = contractTokenBalance;}
        
        if(ignoreLimits) toSwap=contractTokenBalance;

        uint256 totalLiq= _sell.liq+_buy.liq;
        uint256 totalFees= _sell.total+_buy.total;

        uint256 totalLPTokens=toSwap*totalLiq/totalFees;
        uint256 tokensLeft=toSwap-totalLPTokens;
        uint256 LPTokens=totalLPTokens/2;
        uint256 LPBNBTokens=totalLPTokens-LPTokens;
        toSwap=tokensLeft+LPBNBTokens;
        uint256 oldBNB=address(this).balance;
        _swapTokensForBNB(toSwap);
        uint256 newBNB=address(this).balance-oldBNB;
        uint256 LPBNB=(newBNB*LPBNBTokens)/toSwap;
        _addLiquidity(LPTokens,LPBNB);
        uint256 remainingBNB=address(this).balance-oldBNB;
        _distributeBNB(remainingBNB);
    }
    function _distributeBNB(uint256 amountWei) private {
        uint256 totalReward= _sell.reward+_buy.reward;
        uint256 totalMarketing= _sell.mark+_buy.mark;
        uint256 totalFees= _sell.total+_buy.total;
        
        uint256 rewardBNB=amountWei*totalReward/totalFees;
        uint256 marketingBNB=amountWei*totalMarketing/totalFees;
        if (rewardBNB>0){_swapBNBtoRWRD(rewardBNB);}
        if (marketingBNB>0){(bool marketingsuccess, /* bytes memory data */) = payable(marketingWallet).call{value: marketingBNB, gas: 30000}("");
        require(marketingsuccess, "receiver rejected ETH transfer");}
    }
    function _addLiquidity(uint256 amountTokens,uint256 amountBNB) private {
        _addingLP=true;
        router.addLiquidityETH{value: amountBNB}(
            address(this),
            amountTokens,
            0,
            0,
            owner,
            block.timestamp
        );
        _addingLP=false;
        emit LiquidityAdded(amountTokens,amountBNB);
    }
    function _swapTokensForBNB(uint256 amount) private {
        address[] memory path=new address[](2);
        path[0]=address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function _swapBNBtoRWRD(uint256 amountWei) private {
        uint256 balanceBefore = IBEP20(RWRD).balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(RWRD);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountWei}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = IBEP20(RWRD).balanceOf(address(this))-(balanceBefore);

        totalDividends = totalDividends+(amount);
        dividendsPerShare = dividendsPerShare+(dividendsPerShareAccuracyFactor*(amount)/(totalShares));        
    }
    function _shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= _swapThreshold;
    }
/**
 * Owner Functions
 */
    function ownerUpdateBuyTaxes(uint8 liq,uint8 reward,uint8 mark) public onlyOwner {
        require(liq+reward+mark<=25,"Cannot set BuyTaxes over 25%");
        _buy.liq=liq;
        _buy.reward=reward;
        _buy.mark=mark;
        _buy.total=liq+reward+mark;
        emit OwnerUpdateBuyTaxes(liq,reward,mark);
    }
    function ownerUpdateSellTaxes(uint8 liq,uint8 reward,uint8 mark) public onlyOwner {
        require(liq+reward+mark<=25,"Cannot set SellTaxes over 25%");
        _sell.liq=liq;
        _sell.reward=reward;
        _sell.mark=mark;
        _sell.total=liq+reward+mark;
        emit OwnerUpdateSellTaxes(liq,reward,mark);
    }
    function ownerTriggerSwap(bool ignoreLimits) public onlyOwner {
        _swapAndLiquify(ignoreLimits);
        emit OwnerTriggerSwap(ignoreLimits);
    }
    function ownerSetLimits(uint256 maxWallet) public onlyOwner{
        require(maxWallet>=_totalSupply/100,"Cannot set maxTx below 1%");
        _maxWalletSize = maxWallet*10**_decimals;
        emit OwnerSetLimits(maxWallet);
    }
    function ownerSwitchSwapEnabled(bool enabled) public onlyOwner {
        swapEnabled=enabled;
        emit OwnerSwitchSwapEnabled(enabled);
    }
    function ownerSwitchRewardsEnabled(bool enabled) public onlyOwner {
        rewardsEnabled=enabled;
        emit OwnerSwitchRewardsEnabled(enabled);
    }
    function ownerUpdateSwapThreshold(uint256 swapThreshold, uint256 maxSwap) public onlyOwner {
        require(swapThreshold>=1&&maxSwap>=1);
        _swapThreshold=swapThreshold;
        _maxSwapThreshold=maxSwap;
        emit OwnerUpdateSwapThreshold(swapThreshold,maxSwap);
    }
    function ownerSetRewardSettings(uint256 minPeriod, uint256 minDistribution) public onlyOwner{
        _minPeriod = minPeriod;
        _minDistribution = minDistribution;
        emit OwnerSetRewardSetting(minPeriod, minDistribution);
    }
    function ownerSetExcludeFromRewards(address account) public onlyOwner{
        _excludeAccountFromRewards(account);
        emit OwnerSetExcludedFromRewards(account);
    }
    function ownerSetIncludedToRewards(address account) public onlyOwner{
        _includeAccountToRewards(account);
        emit OwnerSetIncludedToRewards(account);
    }
    function ownerSetMarketingWallet(address payable newWallet) public onlyOwner{
        require(newWallet!=marketingWallet,"Cannot set same address than actual marketingWallet");
        marketingWallet = newWallet;
        emit OwnerSetMarketingWallet(newWallet);
    }
    function ownerExcludeFromFees(address account,bool enabled) public onlyOwner {
        isFeeExempt[account]=enabled;
        emit OwnerExcludeFromFees(account,enabled);
    }
    function ownerWithdrawForeignToken(address foreignToken) public onlyOwner {
        // Cannot withdraw this token
        require(foreignToken!=address(this));
        if(foreignToken==RWRD){totalDividends=dividendsPerShare=0;}
        IBEP20 token=IBEP20(foreignToken);
        token.transfer(owner, token.balanceOf(address(this)));
    }
    function ownerWithdrawStuckBNB() public onlyOwner {
        (bool success,) = msg.sender.call{value: (address(this).balance)}("");
        require(success);
    }

/**
 * User Callable Functions 
 */
    function claimDividend() public{
        require(shareholderClaims[msg.sender] + _minPeriod <= block.timestamp,"Can't claim yet");
        _distributeDividend(msg.sender);
    }
/**
 * IBEP20
 */

    receive() external payable { }

    function totalSupply() external pure override returns (uint256) { return _totalSupply; }
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

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]-(amount);
        }
        _transfer(sender, recipient, amount);
        return true;
    }

}