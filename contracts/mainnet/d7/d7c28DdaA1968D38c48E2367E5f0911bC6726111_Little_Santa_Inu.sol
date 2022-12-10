/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

pragma solidity 0.8.15;
// SPDX-License-Identifier: Unlicensed
interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return (msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}


/**
 * @dev Collection of functions related to the address type
 */
library Address {


    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor ()  {
        address msgSender = _msgSender();
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

// pragma solidity >=0.5.0;

interface IFactory02 {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address lpPair);
    function createPair(address tokenA, address tokenB) external returns (address lpPair);
}

interface IPair02 {
    function factory() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
}

interface IRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
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
    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, uint deadline
    ) external payable returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IRouter02 is IRouter01 {
    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}


contract Little_Santa_Inu is Context, IERC20, Ownable {
    using Address for address payable;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFees;

    mapping (address => bool) private _isExcludedFromRewards;

    mapping (address => bool) private _isExcludedFromMaxSellLimit;
    address[] private _excludedFromRewards;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 100_000_000_000* 10**18; // 100MM
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    address public liquidityWallet;
    address payable public marketingWallet = payable(0xf770f3f0f39bA181db835197fCffB8825299A270);

    uint256 private _tFeeTotal;

    string private _name = "Little Santa inu";
    string private _symbol = "LSI";
    uint8 private _decimals = 18;

    address constant private  DEAD = 0x000000000000000000000000000000000000dEaD;
    
    struct Ratios {
        uint16 lp;
        uint16 marketing;
        uint16 rewards;
        uint16 total;
    }
    
    Ratios public ratios = Ratios({
        lp: 2,
        marketing: 3,
        rewards: 3,
        total: 8
    });

    uint256 public totalFees = 8;

    IRouter02 public dexRouter;
    address public dexPair;
    
    bool private _inSwapAndLiquify;
    
    uint256 public maxSellLimitAmount = 1_000_000_000 *10**18;
    uint256 public swapThreshold =  10_000_000* 10**18; //10M => 0.01%

    // all known liquidity pools 
    mapping (address => bool) public automatedMarketMakerPairs;

    
    event SwapThresholdUpdated(uint256 swapThreshold);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event UniswapV2RouterUpdated(address indexed newAddress, address indexed oldAddress);
    event UniswapV2PairUpdated(address indexed newAddress, address indexed oldAddress);
    event MarketingWalletUpdated(address indexed newMarketingWallet, address indexed oldMarketingWallet);
    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);
    event MaxSellLimitAmountUpdated(uint256 amount);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeFromReward(address indexed account);
    event ExcludeFromMaxSellLimit(address indexed account, bool isExcluded);
    event IncludeInReward(address indexed account);

    event FeesUpdated(uint8 totalFees);

    event Burn(uint256 amount);

    event AddAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event SendMarketingDividends(uint256 amount);


    modifier lockTheSwap {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }

    struct tTransferValues { 
      uint256 tAmount;
      uint256 tTransferAmount;
      uint256 tRewardFee;
      uint256 tLiquidityFee;
      uint256 tMarketingFee;
   }

    struct rTransferValues { 
      uint256 rAmount;
      uint256 rTransferAmount;
      uint256 rRewardFee;
      uint256 rLiquidityFee;
      uint256 rMarketingFee;

   }

    constructor ()  {
        _rOwned[_msgSender()] = _rTotal;
        
        dexRouter = IRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
         // Create a uniswap pair for this new token with BNB
        dexPair = IFactory02(dexRouter.factory())
            .createPair(address(this), dexRouter.WETH());

        _setAutomatedMarketMakerPair(dexPair, true);
      
        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[DEAD] = true;

        // exclude pair and other wallets from reward
        excludeFromReward(owner());
        excludeFromReward(address(this));
        excludeFromReward(DEAD);

        _isExcludedFromMaxSellLimit[owner()] = true;
        _isExcludedFromMaxSellLimit[address(this)] = true;

        liquidityWallet = owner();


        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcludedFromRewards[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function totalRewardFeesDistributed() public view returns (uint256) {
        return _tFeeTotal;
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != dexPair, "LSI: The main pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "LSI: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        if(value) {
            excludeFromReward(pair);
        }

        emit AddAutomatedMarketMakerPair(pair, value);
    }

    function deliver(uint256 tAmount) external {
        address sender = _msgSender();
        require(!_isExcludedFromRewards[sender], "LSI: Excluded addresses from reward cannot call this function");
        uint256 rAmount = reflectionFromToken(tAmount);
        _rOwned[sender] -= rAmount;
        _rTotal -= rAmount;
        _tFeeTotal += tAmount;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "LSI: Amount must be less than supply");
        if (!deductTransferFee) {
            uint256 rAmount = reflectionFromToken(tAmount);
            return rAmount;
        } else {
            (, rTransferValues memory rValues) = _getValuesWithFees(tAmount);
            return rValues.rTransferAmount;
        }
    }

    function reflectionFromToken(uint256 tAmount) private view returns(uint256) {
        return tAmount*_getRate();
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "LSI: Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount/currentRate;
    }

    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcludedFromRewards[account], "LSI: Account is already excluded from reward");
        require(_excludedFromRewards.length <= 1000, "LSI: No more than 1000 addresses can be excluded from the rewards");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcludedFromRewards[account] = true;
        _excludedFromRewards.push(account);
        emit ExcludeFromReward(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcludedFromRewards[account], "LSI: Account is already included in reward");
        for (uint256 i = 0; i < _excludedFromRewards.length; i++) {
            if (_excludedFromRewards[i] == account) {
                _excludedFromRewards[i] = _excludedFromRewards[_excludedFromRewards.length - 1];
                _tOwned[account] = 0;
                _isExcludedFromRewards[account] = false;
                _excludedFromRewards.pop();
                break;
            }
        }
        emit IncludeInReward(account);
    }
    
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "LSI: Account has already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function excludeFromMaxSellLimit(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromMaxSellLimit[account] != excluded, "LSI: Account has already the value of 'excluded'");
        _isExcludedFromMaxSellLimit[account] = excluded;
        emit ExcludeFromMaxSellLimit(account, excluded);
    }
    
    function setFees(uint8 newFees) external onlyOwner {
        require(newFees <= 8 && newFees >=0,"LSI: Total fees must be between 0 and 8");
        totalFees = newFees;
        emit FeesUpdated(newFees);
    }
   
    function setMaxSellLimitAmount(uint256 amount) external onlyOwner {
        require(amount >= 1_000_000_000 && amount <= 100_000_000_000, "LSI: Amount must be bewteen 1 000 000 000 and 100 000 000 000");
        maxSellLimitAmount = amount *10**18;
        emit MaxSellLimitAmountUpdated(maxSellLimitAmount);
    }
    
    function setSwapThreshold(uint256 amount) external onlyOwner {
        require(amount >= 1 && amount <= 1_000_000_000, "LSI: Amount must be bewteen 1 and 1 000 000 000");
        swapThreshold = amount *10**18;
        emit SwapThresholdUpdated(amount);

    }
    
     //to recieve BNB from uniswapV2Router when swaping
    receive() external payable {
    }

    function _reflectFee(uint256 rRewardFee, uint256 tRewardFee) private {
        _rTotal -= rRewardFee;
        _tFeeTotal += tRewardFee;
    }


    function _getValuesWithFees(uint256 tAmount) private view returns (tTransferValues memory, rTransferValues memory) {
        tTransferValues memory tValues= _getTValues(tAmount);
        rTransferValues memory rValues= _getRValues(tValues);
        return (tValues,rValues);
    }

    function _getTValues(uint256 tAmount) private view returns (tTransferValues memory) {
        (uint256 tRewardFee, uint256 tLiquidityFee, uint256 tMarketingFee) = _calculateFees(tAmount);
        uint256 tTransferAmount = tAmount - tRewardFee - tLiquidityFee - tMarketingFee;
        return tTransferValues(tAmount,tTransferAmount, tRewardFee, tLiquidityFee, tMarketingFee);
    }

    function _getRValues(tTransferValues memory tValues) private view returns (rTransferValues memory) {
        uint256 currentRate = _getRate();
        uint256 rAmount = tValues.tAmount * currentRate;
        uint256 rRewardFee = tValues.tRewardFee * currentRate;
        uint256 rLiquidityFee = tValues.tLiquidityFee * currentRate;
        uint256 rMarketingFee = tValues.tMarketingFee * currentRate;
        uint256 rTransferAmount = rAmount - rRewardFee - rLiquidityFee - rMarketingFee;
        return rTransferValues(rAmount, rTransferAmount, rRewardFee, rLiquidityFee, rMarketingFee);
    }
    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply /tSupply;
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excludedFromRewards.length; i++) {
            if (_rOwned[_excludedFromRewards[i]] > rSupply || _tOwned[_excludedFromRewards[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply -= _rOwned[_excludedFromRewards[i]];
            tSupply -= _tOwned[_excludedFromRewards[i]];
        }
        if (rSupply < (_rTotal / _tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _calculateFees(uint256 amount) private view returns (uint256,uint256,uint256) {
            return(amount*ratios.rewards/ratios.total/100*totalFees,amount*ratios.lp/ratios.total/100*totalFees,amount*ratios.marketing/ratios.total/100*totalFees);
        
    }
    
    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }
    function isExcludedFromRewards(address account) public view returns(bool) {
        return _isExcludedFromRewards[account];
    }
    function isExcludedFromMaxSellLimit(address account) public view returns(bool) {
        return _isExcludedFromMaxSellLimit[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount >= 0, "BEP20: Transfer amount must be greater or equal to zero");

        bool isSellTransfer = automatedMarketMakerPairs[to];
        if( 
        	!_inSwapAndLiquify &&
            isSellTransfer && 
        	from != address(dexRouter) &&
            !_isExcludedFromMaxSellLimit[to] &&
            !_isExcludedFromMaxSellLimit[from] //no max for those excluded from max transaction amount
        ) {
            require(amount <= maxSellLimitAmount, "LSI: Sell transfer amount exceeds the maxSellLimitAmount.");
        }


        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.        
		uint256 contractTokenBalance = balanceOf(address(this));
        
        bool canSwap = contractTokenBalance >= swapThreshold;
        
        if (
            canSwap &&
            !_inSwapAndLiquify&&
            !automatedMarketMakerPairs[from] && // not during buying
            from != liquidityWallet &&
            to != liquidityWallet
        ) {
            //add liquidity
            _swapAndLiquify(swapThreshold);
        }
        
        bool isBuyTransfer = automatedMarketMakerPairs[from];
        bool takeFee = !_inSwapAndLiquify && (isBuyTransfer || isSellTransfer);

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }
        
        _tokenTransfer(from,to,amount,takeFee);
    }

    function _swapAndLiquify(uint256 totaltokens) private lockTheSwap {
        uint16 totalRatios = ratios.total - ratios.rewards;
        uint256 tokensToNotSwap = totaltokens * ratios.lp / totalRatios / 2;
        uint256 tokensToSwap = totaltokens - tokensToNotSwap;
        // initial BNB amount
        uint256 initialBalance = address(this).balance;
        // swap tokens for BNB
        _swapTokensForBNB(tokensToSwap);
        // how much BNB did we just swap into?
        uint256 newBalance = address(this).balance - initialBalance;

        uint256 liquidityAmount = newBalance * tokensToNotSwap / tokensToSwap;
        // add liquidity to PancakeSwap
        if(tokensToNotSwap > 0)_addLiquidity(tokensToNotSwap, liquidityAmount);
        // send BNB to marketing wallet
        uint256 marketingAmount = address(this).balance - initialBalance;
        marketingWallet.sendValue(marketingAmount);

        emit SwapAndLiquify(tokensToNotSwap, newBalance, tokensToNotSwap);
    }

    function _swapTokensForBNB(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        _approve(address(this), address(dexRouter), tokenAmount);

        // make the swap
        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function _addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(dexRouter), tokenAmount);

        // add the liquidity
        dexRouter.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liquidityWallet, // send to liquidity wallet
            block.timestamp
        );
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        tTransferValues memory tValues;
        rTransferValues memory rValues;

        if(!takeFee) {
            tValues = tTransferValues(amount, amount,0,0,0);
            uint256 rAmount = amount * _getRate();
            rValues = rTransferValues(rAmount, rAmount,0,0,0);
        }
        else {
        (tValues, rValues) = _getValuesWithFees(amount);
        }

        
        if (_isExcludedFromRewards[sender] && !_isExcludedFromRewards[recipient]) {
            _transferFromExcluded(sender, recipient, tValues, rValues);
        } else if (!_isExcludedFromRewards[sender] && _isExcludedFromRewards[recipient]) {
            _transferToExcluded(sender, recipient, tValues, rValues);
        } else if (!_isExcludedFromRewards[sender] && !_isExcludedFromRewards[recipient]) {
            _transferStandard(sender, recipient, rValues);
        } else if (_isExcludedFromRewards[sender] && _isExcludedFromRewards[recipient]) {
            _transferBothExcluded(sender, recipient, tValues, rValues);
        } else {
            _transferStandard(sender, recipient, rValues);
        }

        emit Transfer(sender, recipient, tValues.tTransferAmount);
        if(takeFee)
            _transferFees(tValues, rValues, sender);
    }
    function _transferFees(tTransferValues memory tValues, rTransferValues memory rValues, address sender) private {
        uint256 rFees = rValues.rMarketingFee + rValues.rLiquidityFee;
        uint256 tFees = tValues.tMarketingFee + tValues.tLiquidityFee;
        _rOwned[address(this)] = _rOwned[address(this)] + rFees;
        if(tFees > 0) emit Transfer(sender, address(this), tFees);
        if(_isExcludedFromRewards[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)] + tFees;

        _reflectFee(rValues.rRewardFee, tValues.tRewardFee);

    }

    function _transferStandard(address sender, address recipient, rTransferValues memory rValues) private {
        _rOwned[sender] -= rValues.rAmount;
        _rOwned[recipient] += rValues.rTransferAmount;
    }

    function _transferToExcluded(address sender, address recipient, tTransferValues memory tValues, rTransferValues memory rValues) private {
        _rOwned[sender] -= rValues.rAmount;
        _tOwned[recipient] += tValues.tTransferAmount;
        _rOwned[recipient] += rValues.rTransferAmount;           
    }

    function _transferFromExcluded(address sender, address recipient, tTransferValues memory tValues, rTransferValues memory rValues) private {
        _tOwned[sender] -= tValues.tAmount;
        _rOwned[sender] -= rValues.rAmount;
        _rOwned[recipient] += rValues.rTransferAmount;   
    }

    function _transferBothExcluded(address sender, address recipient, tTransferValues memory tValues, rTransferValues memory rValues) private {
        _tOwned[sender] -= tValues.tAmount;
        _rOwned[sender] -= rValues.rAmount;
        _tOwned[recipient] += tValues.tTransferAmount;
        _rOwned[recipient] += rValues.rTransferAmount;        
    }

    function setNewRouter02(address newRouter_) public onlyOwner {
        IRouter02 newRouter = IRouter02(newRouter_);
        address newPair = IFactory02(newRouter.factory()).getPair(address(this), newRouter.WETH());
        if (newPair == address(0)) {
            newPair = IFactory02(newRouter.factory()).createPair(address(this), newRouter.WETH());
        }
        dexPair = newPair;
        dexRouter = IRouter02(newRouter_);
    }

        // Airdrop
    function batchTokensTransfer(address[] calldata _accounts, uint256[] calldata _amounts) external onlyOwner {
        require(_accounts.length <= 200, "LSI: 200 addresses maximum");
        require(_accounts.length == _amounts.length, "LSI: Account array must have the same size as the amount array");
        for (uint i = 0; i < _accounts.length; i++) {
            if (_accounts[i] != address(0)) {
                _tokenTransfer(_msgSender(),_accounts[i],_amounts[i],false);
            }
        }
    }

    function getCirculatingSupply() external view returns (uint256) {
        return totalSupply() - balanceOf(DEAD)  - balanceOf(address(0));
    }

    function burn(uint256 amount) external returns (bool) {
        _transfer(_msgSender(), DEAD, amount);
        emit Burn(amount);
        return true;
    }

    function swapAndLiquifyManually() external onlyOwner {
        uint256 tokensToSwap = balanceOf(address(this));
        require(tokensToSwap > 0, "LSI: There are no tokens to swap and liquify");
        _swapAndLiquify(tokensToSwap);
    }

    function setMarketingWallet(address payable newWallet) external onlyOwner {
        require(newWallet != marketingWallet, "LSI: The marketing wallet has already that address");
        require(newWallet != address(0), "LSI: The marketing wallet cannot be the 0 address");
        emit MarketingWalletUpdated(newWallet,marketingWallet);
         marketingWallet = newWallet;
    }
    
    function setLiquidityWallet(address payable newWallet) external onlyOwner {
        require(newWallet != liquidityWallet, "LSI: The liquidity wallet has already that address");
        require(newWallet != address(0), "LSI: The liquidity wallet cannot be the 0 address");
        emit LiquidityWalletUpdated(newWallet,liquidityWallet);
         liquidityWallet = newWallet;
    }

    function getStuckBNBs(address payable to) external onlyOwner {
        require(address(this).balance > 0, "LSI: There are no BNBs in the contract");
        to.transfer(address(this).balance);
    } 

    function getStuckTokens(address payable to, address token, uint256 amount) external onlyOwner {
        require(IERC20(token).balanceOf(address(this)) > 0, "LSI: There are tokens in the contract");
        require(token != address(this),"LSI: Little Santa Inu tokens cannot be got from the contract");
        IERC20(token).transfer(to,amount);
    } 
}