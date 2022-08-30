// SPDX-License-Identifier: MIT

import "./Utils.sol";

pragma solidity ^0.8.16;

contract BabyTigeInu is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    using Address for address;
    
    string private _name = "BabyTigeInu";
    string private _symbol = "BTI";
    uint8 private _decimals = 9;
    bool public market_active;

    address payable public marketingWalletAddress = payable(0x97a9a4bD36ce4A40e640C82436d15100310C150a);
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    
    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isMarketPair;


    uint256 public _buyLiquidityFee = 3;
    uint256 public _buyMarketingFee = 2;
    
    uint256 public _sellLiquidityFee = 10;
    uint256 public _sellMarketingFee = 2;

    uint256 public _liquidityShare = 15;
    uint256 public _marketingShare = 85;

    uint256 public _totalTaxIfBuying = 5;
    uint256 public _totalTaxIfSelling = 12;
    uint256 public _totalDistributionShares = 100;

    uint256 public _totalSupply = 1000000000 * 10**_decimals;    
    uint256 public _walletMax = 30000000 * 10**_decimals;      
    uint256 public minimumTokensBeforeSwap = 10000000 * 10**_decimals; 

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public swapAndLiquifyByLimitOnly = false;
    bool public checkWalletLimit = true;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    event SwapETHForTokens(
        uint256 amountIn,
        address[] path
    );
    
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );

    event inSwapAndLiquifyStatus(bool p);
    event stepLiquify(bool overMinimumTokenBalanceStatus,bool inSwapAndLiquifyStatus, bool isMarketPair_sender, bool swapAndLiquifyEnabledStatus);
    event stepFee(bool p);

    event marketingGetBnb(uint256 amount);
    event liquidityGetBnb(uint256 amount);
    event eventSwapAndLiquify(uint256 amount);
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () {
        //Testnet: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 
        //Production: 0x10ED43C718714eb63d5aA57B78B54704E256024E
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;

        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;
        
        _totalTaxIfBuying = _buyLiquidityFee.add(_buyMarketingFee);
        _totalTaxIfSelling = _sellLiquidityFee.add(_sellMarketingFee);
        _totalDistributionShares = _liquidityShare.add(_marketingShare);
        
        isMarketPair[address(uniswapPair)] = true;

        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
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
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function minimumTokensBeforeSwapAmount() public view returns (uint256) {
        return minimumTokensBeforeSwap;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setMarketPairStatus(address account, bool newValue) public onlyOwner {
        isMarketPair[account] = newValue;
    }

    
    function setIsExcludedFromFee(address account, bool newValue) public onlyOwner {
        isExcludedFromFee[account] = newValue;
    }


    function setBuyTaxes(uint256 newLiquidityTax, uint256 newMarketingTax) external onlyOwner() {
         require(newLiquidityTax.add(newMarketingTax) <= 12, "Tax exceeds the 12%.");
        _buyLiquidityFee = newLiquidityTax;
        _buyMarketingFee = newMarketingTax;

        _totalTaxIfBuying = _buyLiquidityFee.add(_buyMarketingFee);
    }

    function setSellTaxes(uint256 newLiquidityTax, uint256 newMarketingTax) external onlyOwner() {
        require(newLiquidityTax.add(newMarketingTax) <= 13, "Tax exceeds the 13%.");
        _sellLiquidityFee = newLiquidityTax;
        _sellMarketingFee = newMarketingTax;

        _totalTaxIfSelling = _sellLiquidityFee.add(_sellMarketingFee);
    }
    
    function setDistributionSettings(uint256 newLiquidityShare, uint256 newMarketingShare) external onlyOwner() {
        _liquidityShare = newLiquidityShare;
        _marketingShare = newMarketingShare;
        _totalDistributionShares = _liquidityShare.add(_marketingShare);
    }
    
    function enableDisableWalletLimit(bool newValue) external onlyOwner {
       checkWalletLimit = newValue;
    }


    function setWalletLimit(uint256 newLimit) external onlyOwner {
        require(newLimit >= 15000000, "Max Wallet min 15000000.");
        _walletMax  = newLimit;
    }

    function setNumTokensBeforeSwap(uint256 newLimit) external onlyOwner() {
        minimumTokensBeforeSwap = newLimit;
    }

    function setMarketingWalletAddress(address newAddress) external onlyOwner() {
        marketingWalletAddress = payable(newAddress);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setSwapAndLiquifyByLimitOnly(bool newValue) public onlyOwner {
        swapAndLiquifyByLimitOnly = newValue;
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress));
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }
    
    function changeRouterVersion(address newRouterAddress) public onlyOwner returns(address newPairAddress) {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(newRouterAddress); 

        newPairAddress = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(address(this), _uniswapV2Router.WETH());

        if(newPairAddress == address(0)) 
        {
            newPairAddress = IUniswapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this), _uniswapV2Router.WETH());
        }

        uniswapPair = newPairAddress; 
        uniswapV2Router = _uniswapV2Router; 

        isMarketPair[address(uniswapPair)] = true;
    }

    receive() external payable {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(market_active,"cannot trade before the market opening");

        if(inSwapAndLiquify)
        { 
            return _basicTransfer(sender, recipient, amount); 
        }
        else
        {           

            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;
            emit stepLiquify(overMinimumTokenBalance,!inSwapAndLiquify,!isMarketPair[sender],swapAndLiquifyEnabled);
            if (overMinimumTokenBalance && !inSwapAndLiquify && !isMarketPair[sender] && swapAndLiquifyEnabled) 
            {
                if(swapAndLiquifyByLimitOnly)
                    contractTokenBalance = minimumTokensBeforeSwap;
                swapAndLiquify(contractTokenBalance);    
            }

            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

            uint256 finalAmount = (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) ? 
                                         amount : takeFee(sender, recipient, amount);

            if(checkWalletLimit && !isMarketPair[recipient] && recipient != owner())
                require(balanceOf(recipient).add(finalAmount) <= _walletMax);

            _balances[recipient] = _balances[recipient].add(finalAmount);
            emit Transfer(sender, recipient, finalAmount);
            return true;
        }
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapAndLiquify(uint256 tAmount) private lockTheSwap {
        
        uint256 tokensForLP = tAmount.mul(_liquidityShare).div(_totalDistributionShares).div(2);
        uint256 tokensForSwap = tAmount.sub(tokensForLP);

        swapTokensForEth(tokensForSwap);
        uint256 amountReceived = address(this).balance;

        emit eventSwapAndLiquify(amountReceived);

        uint256 totalBNBFee = _totalDistributionShares.sub(_liquidityShare.div(2));
        
        uint256 amountBNBLiquidity = amountReceived.mul(_liquidityShare).div(totalBNBFee).div(2);
        uint256 amountBNBMarketing = amountReceived.sub(amountBNBLiquidity);

        if(amountBNBMarketing > 0)
            transferToAddressETH(marketingWalletAddress, amountBNBMarketing);


        if(amountBNBLiquidity > 0 && tokensForLP > 0)
            addLiquidity(tokensForLP, amountBNBLiquidity);

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
        
        emit SwapTokensForETH(tokenAmount, path);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, 
            0, 
            owner(),
            block.timestamp
        );
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = 0;
        
        if(isMarketPair[sender]) {
            feeAmount = amount.mul(_totalTaxIfBuying).div(100); 
        }
        else if(isMarketPair[recipient]) {
            feeAmount = amount.mul(_totalTaxIfSelling).div(100);
        }
        
        if(feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }

        return amount.sub(feeAmount);
    }

    function activate_market(bool active) external onlyOwner {
        market_active = active;
    }


  }