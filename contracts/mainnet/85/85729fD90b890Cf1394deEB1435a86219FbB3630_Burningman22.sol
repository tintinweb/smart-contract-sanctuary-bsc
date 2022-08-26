/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

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

interface IFactoryV2 {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address lpPair);
    function createPair(address tokenA, address tokenB) external returns (address lpPair);
}

interface IV2Pair {
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



contract Burningman22 is IERC20 {
    address private _owner;
    address public originalDeployer;
    address public operator;


    mapping (address => uint256) private _tOwned;
    mapping (address => bool) lpPairs;
    uint256 private timeSinceLastPair = 0;
    mapping (address => mapping (address => uint256)) private _allowances;

   
    mapping (address => bool) private _isExcludedFromFees;

    uint256 constant private startingSupply = 1_000_000_000;
    string constant private _name = "BurningMan22";
    string constant private _symbol = "BM2022";
    uint8 constant private _decimals = 18;

    uint256 constant private _tTotal = startingSupply * 10**_decimals;

    struct Fees {
        uint16 buyFee;
        uint16 sellFee;
        uint16 transferFee;
    }

    Fees public _taxRates = Fees({
        buyFee: 800,
        sellFee: 1800,
        transferFee: 100
    });

     struct user {
        uint256 lastTradeTime;
        uint256 tradeAmount;
    }

    uint256 public TwentyFourhours = 86400;
    uint256 public SellLimit = 5;
    uint256 public maxSellTransactionAmount = 1000000 * 10 ** 18;

    mapping(address => user) public tradeData;

    uint256 constant public maxRoundtripTax = 1000;
    uint256 constant masterTaxDivisor = 10000;

    IRouter02 public dexRouter;
    address public lpPair;
    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;

    struct TaxWallets {
        address payable treasuryReceiver;
    }

    TaxWallets public _taxWallets = TaxWallets({
        treasuryReceiver: payable(0xa620E9619847830CFb99FB81dB9a1F6f10D1DD59)
    });
    
    
    bool public tradingEnabled = false;
  
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    

    modifier onlyOwner() {
        require(_owner == msg.sender, "Caller =/= owner.");
        _;
    }

    constructor () payable {
        _tOwned[msg.sender] = _tTotal;
        emit Transfer(address(0), msg.sender, _tTotal);

        // Set the owner.
        _owner = msg.sender;
        originalDeployer = msg.sender;

        if (block.chainid == 56) {
            dexRouter = IRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        } else if (block.chainid == 97) {
            dexRouter = IRouter02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        } else {
            revert();
        }

        lpPair = IFactoryV2(dexRouter.factory()).createPair(dexRouter.WETH(), address(this));
        lpPairs[lpPair] = true;

        _approve(_owner, address(dexRouter), type(uint256).max);
        _approve(address(this), address(dexRouter), type(uint256).max);

        _isExcludedFromFees[_owner] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[DEAD] = true;
       
    }

    fallback() external payable {}
    receive() external payable { }

    function transferOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Call renounceOwnership to transfer owner to the zero address.");
        require(newOwner != DEAD, "Call renounceOwnership to transfer owner to the zero address.");
        setExcludedFromFees(_owner, false);
        setExcludedFromFees(newOwner, true);
        
        if (balanceOf(_owner) > 0) {
            finalizeTransfer(_owner, newOwner, balanceOf(_owner), false, false );
        }
        
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
        
    }

    function renounceOwnership() external onlyOwner {
        setExcludedFromFees(_owner, false);
        address oldOwner = _owner;
        _owner = address(0);
        emit OwnershipTransferred(oldOwner, address(0));
    }

    function setOperator(address newOperator) external {
        require(msg.sender == originalDeployer, "Can only be called by original deployer.");
        address oldOperator = operator;
        if (oldOperator != address(0)) {
            setExcludedFromFees(oldOperator, false);
        }
        operator = newOperator;
        setExcludedFromFees(newOperator, true);
    }

    function totalSupply() external pure override returns (uint256) { if (_tTotal == 0) { revert(); } return _tTotal; }
    function decimals() external pure override returns (uint8) { if (_tTotal == 0) { revert(); } return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return _owner; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address sender, address spender, uint256 amount) internal {
        require(sender != address(0), "ERC20: Zero Address");
        require(spender != address(0), "ERC20: Zero Address");

        _allowances[sender][spender] = amount;
        emit Approval(sender, spender, amount);
    }

    function approveContractContingency() external onlyOwner returns (bool) {
        _approve(address(this), address(dexRouter), type(uint256).max);
        return true;
    }

   function rescueToken(uint256 tokens) external onlyOwner returns (bool success){
    if (_allowances[msg.sender][address(this)] != type(uint256).max) {
        _allowances[msg.sender][address(this)] -= tokens ;
    }

    return _transfer(address(this), msg.sender, tokens ); 
   }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] -= amount;
        }

        return _transfer(sender, recipient, amount);
    }

    function setNewRouter(address newRouter) external onlyOwner {
        IRouter02 _newRouter = IRouter02(newRouter);
        address get_pair = IFactoryV2(_newRouter.factory()).getPair(address(this), _newRouter.WETH());
        if (get_pair == address(0)) {
            lpPair = IFactoryV2(_newRouter.factory()).createPair(address(this), _newRouter.WETH());
        }
        else {
            lpPair = get_pair;
        }
        dexRouter = _newRouter;
        _approve(address(this), address(dexRouter), type(uint256).max);
    }

    function setLpPair(address pair, bool enabled) external onlyOwner {
        if (!enabled) {
            lpPairs[pair] = false;
  
        } else {
            if (timeSinceLastPair != 0) {
                require(block.timestamp - timeSinceLastPair > 3 days, "3 Day cooldown.!");
            }
            lpPairs[pair] = true;
            timeSinceLastPair = block.timestamp;
       
        }
    }

    function isExcludedFromFees(address account) external view returns(bool) {
        return _isExcludedFromFees[account];
    }

  
    function setExcludedFromFees(address account, bool enabled) public onlyOwner {
        _isExcludedFromFees[account] = enabled;
    }


    function getCirculatingSupply() public view returns (uint256) {
        return (_tTotal - (balanceOf(DEAD) + balanceOf(address(0))));
    }

    function setSellLimit(uint _sellLimit) external onlyOwner {
        SellLimit = _sellLimit;
    }

    function setTwentyFourhours(uint256 _time) external onlyOwner {
        TwentyFourhours = _time;
    }

    function setTaxes(uint16 buyFee, uint16 sellFee, uint16 transferFee) external onlyOwner {
        require(buyFee + sellFee <= maxRoundtripTax, "Cannot exceed roundtrip maximum.");
        _taxRates.buyFee = buyFee;
        _taxRates.sellFee = sellFee;
        _taxRates.transferFee = transferFee;
    }

    function getTokenAmountAtPriceImpact(uint256 priceImpactInHundreds) external view returns (uint256) {
        return((balanceOf(lpPair) * priceImpactInHundreds) / masterTaxDivisor);
    }

    function setMaxSellTransaction(uint256 _maxTxn) external onlyOwner {
        maxSellTransactionAmount = _maxTxn;
    }


    function _transfer(address from, address to, uint256 amount) internal returns (bool) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        bool buy = false;
        bool sell = false;
        bool other = false;
        if (lpPairs[from]) {
            buy = true;
        } else if (lpPairs[to]) {
            sell = true;
        } else {
            other = true;
        }


        bool excludedAccount = _isExcludedFromFees[from] || _isExcludedFromFees[to];
        require(tradingEnabled || excludedAccount, "Trading not started");

        
        if (lpPairs[to] && !excludedAccount) {
            require(amount <= maxSellTransactionAmount, "Error amount");

            uint blkTime = block.timestamp;
          
            uint256 maxPercentVal = balanceOf(from) * SellLimit / 100; 
            require(amount <= maxPercentVal, "ERR: Can't sell more than set %");
            
            if( blkTime > tradeData[from].lastTradeTime + TwentyFourhours) {
                tradeData[from].lastTradeTime = blkTime;
                tradeData[from].tradeAmount = amount;
            }
            else if( (blkTime < tradeData[from].lastTradeTime + TwentyFourhours) && (( blkTime > tradeData[from].lastTradeTime)) ){
                require(tradeData[from].tradeAmount + amount <= maxPercentVal, "ERR: Can't sell more than % in One day");
                tradeData[from].tradeAmount = tradeData[from].tradeAmount + amount;
            }
        } 

        return finalizeTransfer(from, to, amount, buy, sell );
    }

    function _basicTransfer(address from, address to, uint256 amount) internal returns (bool) {
        _tOwned[from] -= amount;
        _tOwned[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }


    function enableTrading(bool _tradingEnabled) public onlyOwner {
        tradingEnabled = _tradingEnabled;
    }

    function sweepContingency() external onlyOwner {
        payable(_owner).transfer(address(this).balance);
    }

    function multiSendTokens(address[] memory accounts, uint256[] memory amounts) external onlyOwner {
        require(accounts.length == amounts.length, "Lengths do not match.");
        for (uint8 i = 0; i < accounts.length; i++) {
            require(balanceOf(msg.sender) >= amounts[i]);
            finalizeTransfer(msg.sender, accounts[i], amounts[i]*10**_decimals, false, false );
        }
    }

    function finalizeTransfer(address from, address to, uint256 amount, bool buy, bool sell ) internal returns (bool) {
      
        
        bool takeFee = true;
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]){
            takeFee = false;
        }

        _tOwned[from] -= amount;
        uint256 amountReceived = (takeFee) ? takeTaxes(from, buy, sell, amount) : amount;
        _tOwned[to] += amountReceived;

        emit Transfer(from, to, amountReceived);
        return true;
    }

    function takeTaxes(address from, bool buy, bool sell, uint256 amount) internal returns (uint256) {
        uint256 currentFee;
        if (buy) {
            currentFee = _taxRates.buyFee;
        } else if (sell) {
            currentFee = _taxRates.sellFee;
        } else {
            currentFee = _taxRates.transferFee;
        }
        
        uint256 feeAmount = amount * currentFee / masterTaxDivisor;
        if (feeAmount > 0) {
            _tOwned[_taxWallets.treasuryReceiver] += feeAmount;
            emit Transfer(from, _taxWallets.treasuryReceiver, feeAmount);
        }

        return amount - feeAmount;
    }
}