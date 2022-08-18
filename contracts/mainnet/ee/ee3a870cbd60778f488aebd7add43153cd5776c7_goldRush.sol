/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function multiTransfer(address[] memory recipients, uint256[] memory amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);

        
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is still locked");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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

contract goldRush is Context, IBEP20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) public _isExcludedFromAutoLiquidity;
    
    // A whale thing!
    mapping(address => bool) private _isExcludedFromMaxTx;
    mapping(address => bool) public _isExcludedFromAntiWhale;

    //Anti bot thing
    mapping(address => bool) public _isBlacklisted;
    mapping(address => bool) private _isTimelockExempt;

    mapping(address => bool) public allowedTransfer;

    // auto liquidity
    IUniswapV2Router02 public uniswapV2Router;
    address            public uniswapV2Pair;

    address private _teamWallet;
    address private _marketingWallet;
    address private _lpFeeReceiver;
    address private _deployer;

    address public constant _burnAddress = 0x000000000000000000000000000000000000dEaD;

    uint256 private _totalSupply = 100000000000 * 10**9;

    string private constant _name     = "GoldRush";
    string private constant _symbol   = "GRUSH";
    uint8  private constant _decimals = 9;

    uint256 private  _percentageOfLiquidityForTeam      = 0;
    uint256 private  _percentageOfLiquidityForMarketing = 8000;

    //W2W Tax Fee
    uint256 public _liquidityFee =  0;
    //Buy Tax Fee
    uint256 public _liquidityBuyFee = 8;
    //Sell Tax Fee
    uint256 public _liquiditySellFee = 8;

    uint256 public _maxTxAmount     = _totalSupply * 200 / 10000; // 2% of the total supply
    uint256 public _minTokenBalance = _totalSupply / 400;

    // no big willies
    bool    public _isAntiWhaleEnabled = true;
    uint256 public _antiWhaleThreshold = _totalSupply * 200 / 10000; // 2% of total supply

    // Cooldown & timer functionality
    bool public opCooldownEnabled = true;
    uint8 public cooldownTimerInterval = 60 seconds;
    mapping (address => uint) private cooldownTimer;

    //Anti snipe
    uint256 public launch_block;
    uint256 private deadline = 5;
    bool private tradingEnabled = false;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 bnbReceived,
        uint256 tokensIntoLiquidity
    );

    event TeamSent(address to, uint256 bnbSent);
    event MarketingSent(address to, uint256 bnbSent);
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(
        address _mwallet,
        address _twallet,
        address _lpwallet,
        address _dwallet
    ) {
        _balances[_msgSender()] = _totalSupply;

        _teamWallet       = _mwallet;
        _marketingWallet  = _twallet;
        _lpFeeReceiver    = _lpwallet;
        _deployer         = _dwallet;

        // uniswap
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

            // exclude system contracts
        _isExcludedFromFee[owner()]       = true;
        _isExcludedFromFee[address(this)] = true;

        _isExcludedFromAutoLiquidity[uniswapV2Pair]            = true;
        _isExcludedFromAutoLiquidity[address(uniswapV2Router)] = true;

        // No timelock for these people
        _isTimelockExempt[msg.sender] = true;
        _isTimelockExempt[_burnAddress] = true;
        _isTimelockExempt[address(this)] = true;

        _isExcludedFromAntiWhale[owner()]                  = true;
        _isExcludedFromAntiWhale[address(this)]            = true;
        _isExcludedFromAntiWhale[uniswapV2Pair]            = true;
        _isExcludedFromAntiWhale[address(uniswapV2Router)] = true;
        _isExcludedFromAntiWhale[_burnAddress]             = true;
        _isExcludedFromAntiWhale[address(_deployer)] = true;
        
        _isExcludedFromMaxTx[owner()] = true;

        allowedTransfer[msg.sender] = true;
        allowedTransfer[address(uniswapV2Router)] = true;
        allowedTransfer[address(uniswapV2Pair)] = true;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function cSupply() public view returns(uint256) {
        return _totalSupply - balanceOf(_burnAddress);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function multiTransfer(address[] memory recipients, uint256[] memory amount) public override returns (bool) {
        for(uint i=0; i < recipients.length; i++){
            _transfer(_msgSender(), recipients[i], amount[i]);
        }
        return true;
    }

    function bulkBlacklist(address[] memory accounts) external onlyOwner  returns (bool) {
        for(uint i=0; i < accounts.length; i++){
            _isBlacklisted[accounts[i]] = true;
        }
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    function setAllowedTransfer(address account, bool e) external onlyOwner {
        allowedTransfer[account] = e;
    }

     function setExcludedFromFee(address account, bool e) external onlyOwner {
        _isExcludedFromFee[account] = e;
    }

    function setMinTokenBalance(uint256 minTokenBalance) external onlyOwner {
        _minTokenBalance = minTokenBalance * (10**9);
    }

    function setExcludedFromAntiWhale(address account, bool e) external onlyOwner {
        _isExcludedFromAntiWhale[account] = e;
    }

    function setAntiWhaleEnabled(bool e) external onlyOwner {
        _isAntiWhaleEnabled = e;
    }

    function setBlacklist(address account,bool e) external onlyOwner {
        _isBlacklisted[account] = e;
    }

    function setExcludedFromMaxTx(address account, bool e) external onlyOwner {
        _isExcludedFromMaxTx[account] = e;
    }

    function setMaxTxAmount(uint256 amount) external onlyOwner {
        _maxTxAmount = amount * (10**9);
    }

    function setFeesTransfer(uint liquidityFee) external onlyOwner {
        _liquidityFee = liquidityFee;
        require(liquidityFee + _liquiditySellFee + _liquidityBuyFee < 25 , "BEP20: Total fees can't be higher than 20%");
    }

    function setBuyFees(uint liquidityFee) external onlyOwner {
        _liquidityBuyFee = liquidityFee;
        require(liquidityFee + _liquiditySellFee + liquidityFee < 25 , "BEP20: Total fees can't be higher than 20%");
    }

    function setSellFees(uint liquidityFee) external onlyOwner {
    _liquiditySellFee = liquidityFee;
    require(liquidityFee + _liquidityBuyFee + liquidityFee < 25 , "BEP20: Total fees can't be higher than 20%");
    }

    // enable cooldown between trades
    function cooldownEnabled(bool _status, uint8 _interval) public onlyOwner {
        opCooldownEnabled = _status;
        cooldownTimerInterval = _interval * 1 seconds;
    
        require(_interval <= 300, "cooldown timer cannot exceed 5 minutes");
    }

    function setAddresses(address teamWallet, address marketingWallet, address lpFeeReceiver) external onlyOwner {
        _teamWallet       = teamWallet;
        _marketingWallet  = marketingWallet;
        _lpFeeReceiver    = lpFeeReceiver;
    }

    function setLiquidityPercentages(uint256 teamFee, uint256 marketingFee) external onlyOwner {
        _percentageOfLiquidityForTeam        = teamFee;
        _percentageOfLiquidityForMarketing  = marketingFee;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    
    receive() external payable {}

    function setUniswapRouter(address r) external onlyOwner {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(r);
        uniswapV2Router = _uniswapV2Router;
    }

    function setUniswapPair(address p) external onlyOwner {
        uniswapV2Pair = p;
    }

    function setExcludedFromAutoLiquidity(address a, bool b) external onlyOwner {
        _isExcludedFromAutoLiquidity[a] = b;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function EnableTrading() external onlyOwner {
        require(!tradingEnabled, "Cannot re-enable trading");
        tradingEnabled = true;
        launch_block = block.number;
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
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!_isBlacklisted[from], "BEP20: Sender is blacklisted");
        require(!_isBlacklisted[to], "BEP20: Reciever is blacklisted");

        if(!tradingEnabled){
            require(allowedTransfer[from],"Trading is not enabled");
        }

        if (!_isExcludedFromMaxTx[from]) {
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }

        /*
            - swapAndLiquify will be initiated when token balance of this contract
            has accumulated enough over the minimum number of tokens required.
            - don't get caught in a circular liquidity event.
            - don't swapAndLiquify if sender is uniswap pair.
        */
        uint256 contractTokenBalance = balanceOf(address(this));
        
        if (contractTokenBalance >= _maxTxAmount) {
            contractTokenBalance = _maxTxAmount;
        }
        
        bool isOverMinTokenBalance = contractTokenBalance >= _minTokenBalance;
        if (
            isOverMinTokenBalance &&
            !inSwapAndLiquify &&
            !_isExcludedFromAutoLiquidity[from] &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = _minTokenBalance;
            swapAndLiquify(contractTokenBalance);
        }

        bool takeFee = true;
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        _tokenTransfer(from, to, amount, takeFee);

        if (from == uniswapV2Pair &&
            opCooldownEnabled &&
            !_isTimelockExempt[to]) {
            require(cooldownTimer[to] < block.timestamp,"Please wait for 1min between two operations");
            cooldownTimer[to] = block.timestamp + cooldownTimerInterval;
        }

        /*
            anti whale: when buying, check if sender balance will be greater than anti whale threshold
            if greater, throw error
        */
        if ( _isAntiWhaleEnabled && !_isExcludedFromAntiWhale[to] ) {
            require(balanceOf(to) <= _antiWhaleThreshold, "Anti whale: can't hold more than the specified threshold");
        }
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) internal {

        bool isBuy  = sender == uniswapV2Pair && recipient != address(uniswapV2Router);
        bool isSell = recipient == uniswapV2Pair;

        uint256 tokenAmount;
        uint256 feeAmount = 0;
        uint256 feeTax;

        if(!takeFee) {
        tokenAmount = amount;
        feeAmount = 0;
        feeTax = 0;
        } else if (isBuy) {
        feeAmount = ( amount * _liquidityBuyFee ) / 100;
        tokenAmount = amount - feeAmount;
        feeTax = _liquidityBuyFee;
        } else if (isSell) {
        feeAmount = ( amount * _liquiditySellFee ) / 100;
        tokenAmount = amount - feeAmount;
        feeTax = _liquiditySellFee;
        }

        // send to receiver
        basicTransfer(sender, recipient, tokenAmount);
        if(feeAmount > 0) {
            if( feeTax > 0) {
                basicTransfer(sender,address(this), feeAmount);
            }
        }
    }

    function basicTransfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split contract balance into halves
        uint256 half      = contractTokenBalance / 2;
        uint256 otherHalf = contractTokenBalance - half;

        uint256 initialBalance = address(this).balance;

        swapTokensForBnb(half);

        uint256 newBalance = address(this).balance - initialBalance;
        uint256 bnbForTeam       = newBalance / 10000 * _percentageOfLiquidityForTeam;
        uint256 bnbForMarketing = newBalance / 10000 * _percentageOfLiquidityForMarketing;
        uint256 bnbForLiquidity = newBalance - bnbForTeam - bnbForMarketing;

        if ( bnbForTeam != 0 ) {
            emit TeamSent(_teamWallet, bnbForTeam);
            payable(_teamWallet).transfer(bnbForTeam);
        }
        if ( bnbForMarketing != 0 ) {
            emit MarketingSent(_marketingWallet, bnbForMarketing);
            payable(_marketingWallet).transfer(bnbForMarketing);
        }
        
        (uint256 tokenAdded, uint256 bnbAdded) = addLiquidity(otherHalf, bnbForLiquidity);
        
        emit SwapAndLiquify(half, bnbAdded, tokenAdded);
    }

    function swapTokensForBnb(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private returns (uint256, uint256) {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        (uint amountToken, uint amountETH, ) = uniswapV2Router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(_lpFeeReceiver),
            block.timestamp
        );
        return (uint256(amountToken), uint256(amountETH));
    }

    function rescueBNB(uint256 weiAmount) external onlyOwner {
        payable(_deployer).transfer(weiAmount);
    }

    function rescueBSC20(address tokenAdd, uint256 amount) external onlyOwner {
        IBEP20(tokenAdd).transfer(_deployer, amount);
    }
    
}