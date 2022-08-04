//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import 'Util.sol';

contract MrGrow is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _owned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _excluded;
    mapping (address => bool) public _automatedMarketMakerPairs;
    mapping (address => bool) private _internal;

    address public _growFundWallet = 0xbaD2B01b89686e527267AaCcfd052D44360FCBAd;
    address public _addLiqWallet = 0xbaD2B01b89686e527267AaCcfd052D44360FCBAd;
    uint256 private _tSupply = 10000000 * 10**9;
    uint256 public _maxWallet = (_tSupply * 2) / 100;

    string private _name = "Mr. Grow";
    string private _symbol = "MRGROW";
    uint8 private _decimals = 9;

    uint256 public _Fee = 10;
    uint256 private immutable _liquidityFeePercentage = 20;
    uint256 private immutable _growFundFeePercentage = 80;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapV2Pair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    
    bool public _launched = false;
    bool public _limits = true;

    uint256 private minTokensToLiquify = 300 * 10**9;
    uint256 private maxTokensToLiquify = 100000 * 10**9;

    address private DEAD = 0x000000000000000000000000000000000000dEaD;

    event Launched(bool isLaunched);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SetLimits(bool value);
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () {
        _owned[owner()] = _tSupply;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;

        _setAutomatedMarketMakerPair(uniswapV2Pair, true);
        _excluded[owner()] = true;
        _excluded[address(this)] = true;
        _internal[address(0x10ED43C718714eb63d5aA57B78B54704E256024E)] = true;
        
        emit Transfer(address(0), owner(), _tSupply);
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
        return _tSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _owned[account];
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

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    
    function excludeFromFee(address account) public onlyOwner {
        _excluded[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _excluded[account] = false;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function launch() public onlyOwner {
        _launched = true;
        emit Launched(_launched);
    }

    function setLimits(bool limits) public onlyOwner {
        _limits = limits;
        emit SetLimits(limits);
    }

    receive() external payable {}
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _excluded[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(!_excluded[from] && !_excluded[to] && !_automatedMarketMakerPairs[to] && to != address(DEAD) && to != address(0))
        require(_launched, "Token is not launched yet");
        
        checkMaxWallet(from, to, amount);

        uint256 contractTokenBalance = balanceOf(address(this));
        
        bool overMinTokenBalance = contractTokenBalance >= minTokensToLiquify;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            swapAndLiquifyEnabled &&
            !_excluded[from] &&
            !_excluded[to] &&
            !_automatedMarketMakerPairs[from]
        ) {
            if(contractTokenBalance > maxTokensToLiquify) {
                swapAndLiquify(maxTokensToLiquify);
            } else {
                swapAndLiquify(contractTokenBalance);
            } 
        }

        bool isEnableFee = false;
        if (_automatedMarketMakerPairs[to] && !_excluded[to] && !_excluded[from] && _Fee > 0) {
            isEnableFee = true;
        }
        
        (uint256 resultAmount, uint256 fees) = (amount, 0);

       if(isEnableFee) {
           (resultAmount, fees) = _getValues(amount);
           _transferToken(from, address(this), fees);
       }
       _transferToken(from, to, resultAmount);

    }
    function checkMaxWallet(address from, address to, uint256 amount) internal view {
        if(!_excluded[from] && !_excluded[to] && !_automatedMarketMakerPairs[to] && !_internal[to] && to != address(DEAD) && to != address(0) && _limits){
            require((_owned[to].add(amount)) <= _maxWallet, "Exceeds maximum wallet amount.");}
    }
    function swapAndLiquify(uint256 tokensToLiquify) private lockTheSwap {
        uint256 singlePart = tokensToLiquify.div(100);
        uint256 growFundPart = tokensToLiquify.sub(singlePart.mul(_liquidityFeePercentage));
        uint256 liquidityPart = tokensToLiquify.sub(growFundPart);
        uint256 liquidityToLiquify = liquidityPart.div(2);
        uint256 liquidityToAdd = liquidityPart.sub(liquidityToLiquify);
        uint256 toSwap = tokensToLiquify.sub(liquidityToAdd);

        uint256 initialBalance = address(this).balance;

        swapTokensForEth(toSwap);
        uint256 newBalance = address(this).balance.sub(initialBalance);
        uint256 toLiquidity = newBalance.div(9);
        addLiquidity(liquidityToAdd, toLiquidity);
        uint256 balanceToSendGrowFund = address(this).balance;
        payable(_growFundWallet).transfer(balanceToSendGrowFund);

        emit SwapAndLiquify(liquidityToLiquify, newBalance, liquidityToAdd);
    }
   
    function swapTokensForEth(uint256 tokenAmount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, 
            0, 
            address(_addLiqWallet),
            block.timestamp
        );
    }

    function _transferToken(address sender, address recipient, uint256 _amount) private {
        _owned[sender] = _owned[sender].sub(_amount);
        _owned[recipient] = _owned[recipient].add(_amount);   
        emit Transfer(sender, recipient, _amount);
    } 

    function _getValues(uint256 _amount) private view returns (uint256, uint256) {
        uint256 fees = 0;
        fees = calculateFee(_amount);    
        uint256 transferAmount = _amount.sub(fees);
        return (transferAmount, fees);
    }

    function calculateFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_Fee).div(
            10**2
        );
    }
    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "The pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }
    function setInternal(address addr, bool value) public onlyOwner {
        _internal[addr] = value;
    }
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        _automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }
    function setMaxTokensToLiquify(uint256 amount) public onlyOwner {
        require(amount <= 100000, "Variable cannot exceed 1 percent of the total supply.");
        maxTokensToLiquify = amount * 10**9;
    }
    function setFee(uint256 fee) public onlyOwner {
        require(fee >= 0 && fee <= 20, "Fee cannot exceed 20 percent.");
        _Fee = fee;
    }
    function setGrowFundAddress(address adr) public onlyOwner {
        _growFundWallet = adr;
    }
    function setAddLiqWallet(address adr) public onlyOwner {
        _addLiqWallet = adr;
    }
    function setMaxWallet(uint256 amount) public onlyOwner {
        require(amount >= 2 && amount <= 5, "Variable cannot be lower than 2 and exceed 5 percent.");
        _maxWallet = (_tSupply * amount) / 100;
    }
}