/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

interface IERC20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
   
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02{
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract YeagerInuBnB is Context, IERC20Metadata, Ownable {

    struct governingTaxes{
        uint32 _totalTaxPercent;
        uint32 _split0;
        uint32 _split1;
        uint32 _split2;
        uint32 _split3;
        uint32 _split4;
        address payable _wallet1;
        address payable _wallet2;
    }

    governingTaxes[] private _governingTaxes;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isLiquidityPool;

    uint256 private constant _startingSupply = 100_000_000_000_000_000; //100 Quadrillion
    
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = _startingSupply * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    
    string private constant _name = "Yeager Inu";
    string private constant _symbol = "YEAGER";
    uint8 private constant _decimals = 9;

    address public constant burnAddress = 0x000000000000000000000000000000000000dEaD; 
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    uint256 public _maxTxAmount = _tTotal;
    uint256 public _maxHoldAmount = _tTotal;
    uint256 public _swapThreshold;
    mapping (address => bool) private _isBlacklisted;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    event SwapTokensForEth(bool status);
    event AddLiquidity(bool status);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (address wallet1_,  address wallet2_) {
        
        /*
            Total Tax Percentage per Transaction : 13%
            Tax Split (total 100%):
                > Burn (burnAddress): 0%
                > Dev Wallet (wallet1): 15%
                > Marketing Wallet (wallet2): 45% 
                > Auto Liquidity: 23%
                > Holders (reflect): 17%
        */

        /*
            >>> First 24 hour Tax <<<

            > Buy <
            Total Tax Percentage per Transaction : 13%
            Tax Split (total 100%):
                > Burn (burnAddress): 0%
                > Dev Wallet (wallet1): 15%
                > Marketing Wallet (wallet2): 45% 
                > Auto Liquidity: 23%
                > Holders (reflect): 17%

            > Sell <
            Total Tax Percentage per Transaction : 25%
            Tax Split (total 100%):
                > Burn (burnAddress): 0%
                > Dev Wallet (wallet1): 15%
                > Marketing Wallet (wallet2): 45% 
                > Auto Liquidity: 23%
                > Holders (reflect): 17%
        */

        _governingTaxes.push(governingTaxes(13, 0, 15, 45, 23, 17, payable(wallet1_), payable(wallet2_)));
        _governingTaxes.push(governingTaxes(13, 0, 15, 45, 23, 17, payable(wallet1_), payable(wallet2_)));

        _rOwned[_msgSender()] = _rTotal;
        _maxTxAmount = _tTotal;

        excludeFromFee(owner());
        excludeFromFee(address(this));
        excludeFromReward(owner());
        excludeFromReward(burnAddress);
        excludeFromReward(address(this));
        
        emit Transfer(address(0x0000000000000000000000000000000000000000), _msgSender(), _tTotal);
    }

    function name() public pure override returns (string memory) {
        return _name;
    }

    function symbol() public pure override returns (string memory) {
        return _symbol;
    }

    function decimals() public pure override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function buyTaxes() public view 
    returns (
        uint32 total_Tax_Percent,
        uint32 burn_Split,
        uint32 governingSplit_Wallet1,
        uint32 governingSplit_Wallet2,
        uint32 autoliquidity_Split,
        uint32 reflect_Split
    ) {
        return (
            _governingTaxes[0]._totalTaxPercent,
            _governingTaxes[0]._split0,
            _governingTaxes[0]._split1,
            _governingTaxes[0]._split2,
            _governingTaxes[0]._split3,
            _governingTaxes[0]._split4
        );
    }

    function sellTaxes() public view 
    returns (
        uint32 total_Tax_Percent,
        uint32 burn_Split,
        uint32 governingSplit_Wallet1,
        uint32 governingSplit_Wallet2,
        uint32 autoliquidity_Split,
        uint32 reflect_Split
    ) {
        return (
            _governingTaxes[1]._totalTaxPercent,
            _governingTaxes[1]._split0,
            _governingTaxes[1]._split1,
            _governingTaxes[1]._split2,
            _governingTaxes[1]._split3,
            _governingTaxes[1]._split4
        );
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function isBlacklisted(address account) public view returns (bool) {
        return _isBlacklisted[account];
    }

    function setTaxes(
        uint256 type_,
        uint32 totalTaxPercent_, 
        uint32 split0_, 
        uint32 split1_, 
        uint32 split2_, 
        uint32 split3_,
        uint32 split4_, 
        address wallet1_, 
        address wallet2_
    ) external onlyOwner() {
        require(wallet1_ != address(0) && wallet2_ != address(0), "Tax Wallets assigned zero address !");
        require(split0_+split1_+split2_+split3_+split4_ == 100, "Split Percentages does not sum upto 100 !");

        _governingTaxes[type_]._totalTaxPercent = totalTaxPercent_;
        _governingTaxes[type_]._split0 = split0_;
        _governingTaxes[type_]._split1 = split1_;
        _governingTaxes[type_]._split2 = split2_;
        _governingTaxes[type_]._split3 = split3_;
        _governingTaxes[type_]._split4 = split4_;
        _governingTaxes[type_]._wallet1 = payable(wallet1_);
        _governingTaxes[type_]._wallet2 = payable(wallet2_);
    }

    function setBlacklistAccount(address account, bool enabled) external onlyOwner() {
        _isBlacklisted[account] = enabled;
    }

    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
        require(maxTxAmount >= (_tTotal / 1000), "Max Transaction amt must be above 0.1% of total supply"); // Cannot set lower than 0.1%
        _maxTxAmount = maxTxAmount;
    }

    function setMaxHoldAmount(uint256 maxHoldAmount) external onlyOwner() {
        require(maxHoldAmount >= (_tTotal / 1000), "Max Hold amt must be above 0.1% of total supply"); // Cannot set lower than 0.1%
        _maxHoldAmount = maxHoldAmount;
    }

    function setSwapThreshold(uint256 amount) public onlyOwner() {
        _swapThreshold = amount;
    }

    function setUniswapPair(address _uniswapV2Pair) public onlyOwner() {
        uniswapV2Pair = _uniswapV2Pair;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,) = _getValues(tAmount, 1);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,) = _getValues(tAmount, 1);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount / currentRate;
    }

    function reflect(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,) = _getValues(tAmount, 1);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rTotal = _rTotal - rAmount;
        _tFeeTotal = _tFeeTotal + tAmount;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
    
        uint256 type_;
        if (from == uniswapV2Pair) type_ = 0;
        else type_ = 1;

        if (from != owner() && to != owner() && to != burnAddress) {

            if(!inSwap) {
                require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount");
                require(!isBlacklisted(from) || !isBlacklisted(to), "Sniper Rejected");
                if (to != uniswapV2Pair) require(balanceOf(to)+amount <= _maxHoldAmount, "Receiver address exceeds the maxHoldAmount");
            }

            if (!inSwap && from != uniswapV2Pair && swapEnabled) {
                governingTaxes memory _localtax = _governingTaxes[type_];

                uint256 contractTokenBalance = balanceOf(address(this));

                if (contractTokenBalance > _swapThreshold) {
                    uint256 swapTokenBalance = (contractTokenBalance / (_localtax._split1 + _localtax._split2 + _localtax._split3)) * (_localtax._split1 + _localtax._split2);
                    uint256 liquidityTokenBalance = contractTokenBalance - swapTokenBalance;

                    if(swapTokenBalance > 0) {
                        swapTokensForEth(swapTokenBalance);
                    }

                    uint256 contractETHBalance = address(this).balance;
                    uint256 walletETHBalance = (contractETHBalance / (_localtax._split1 + _localtax._split2 + _localtax._split3)) * (_localtax._split1 + _localtax._split2);
                    uint256 liquidityETHBalance = contractETHBalance - walletETHBalance;

                    if(walletETHBalance > 0) {
                        sendETHToFee(walletETHBalance, type_);
                    }

                    if(liquidityTokenBalance > 0 && liquidityETHBalance > 0) {
                        addLiquidityLocal(liquidityTokenBalance, liquidityETHBalance);
                    }
                }
            }
        }
		
        _tokenTransfer(from,to,amount,type_);
    }

    receive() external payable {}

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function excludeFromReward(address account) public onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) public onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        try uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            )
        {
            emit SwapTokensForEth(true);
        }
        catch Error(string memory /*reason*/) {
            emit SwapTokensForEth(false);
        }

    }
        
    function sendETHToFee(uint256 amount, uint256 type_) private {

        governingTaxes memory _localtax = _governingTaxes[type_];

        uint256 wsplit1 = (amount * _localtax._split1) / (_localtax._split1 + _localtax._split2);
        uint256 wsplit2 = amount - wsplit1;

        _localtax._wallet1.transfer(wsplit1);
        _localtax._wallet2.transfer(wsplit2);
    }

    function addLiquidityLocal(uint256 tokenAmount, uint256 ethAmount) private {
        if (allowance(address(this), address(uniswapV2Router)) <= tokenAmount) {
            _approve(address(this), address(uniswapV2Router), ~uint256(0));
        }

        // add the liquidity
        try uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        ) {
            emit AddLiquidity(true);
        } catch Error(string memory /*reason*/) {
            emit AddLiquidity(false);
        }
    }
    
    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        swapEnabled = true;
        tradingOpen = true;
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
    }
    
    function removeStrictTxLimit() public onlyOwner {
        _maxTxAmount = 1e12 * 10**9;
    }
        
    function _tokenTransfer(address sender, address recipient, uint256 amount,uint256 type_) private {
        _transferStandard(sender, recipient, amount, type_);
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount, uint256 type_) private {

        
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount, 0);
        
        if(!_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient]) {
            _rOwned[sender] = _rOwned[sender] - rAmount;
            _rOwned[recipient] = _rOwned[recipient] + rTransferAmount; 
            
            if (_isExcluded[sender]) _tOwned[sender] = _tOwned[sender] - tAmount;
            if (_isExcluded[recipient]) _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        
            uint256 _rfee4 = _rsplitTax(rFee, type_);
            uint256 _tfee4 = _tsplitTax(sender, tFee, type_);
            
            _reflectFee(_rfee4, _tfee4);

            emit Transfer(sender, recipient, tTransferAmount);
        }
        else {
            _rOwned[sender] = _rOwned[sender] - rAmount;
            _rOwned[recipient] = _rOwned[recipient] + rAmount; 

            if (_isExcluded[sender]) _tOwned[sender] = _tOwned[sender] - tAmount;
            if (_isExcluded[recipient]) _tOwned[recipient] = _tOwned[recipient] + tAmount;

            emit Transfer(sender, recipient, tAmount);
        }
    }

    function _rsplitTax(uint256 rFee, uint256 type_) private returns (uint256) {

        governingTaxes memory _localtax = _governingTaxes[type_];

        uint256 _rfee0 = (rFee / 10**2) * _localtax._split0;
        uint256 _rfee123 = (rFee / 10**2) * (_localtax._split1+_localtax._split2+_localtax._split3);
        uint256 _rfee4 = rFee - _rfee0 - _rfee123;
        
        _rOwned[burnAddress] = _rOwned[burnAddress] + _rfee0;
        _rOwned[address(this)] = _rOwned[address(this)] + _rfee123;

        return _rfee4;
    }

    function _tsplitTax(address sender, uint256 tFee, uint256 type_) private returns (uint256) {

        governingTaxes memory _localtax = _governingTaxes[type_];

        uint256 _tfee0 = (tFee / 10**2) * _localtax._split0;
        uint256 _tfee123 = (tFee / 10**2) * (_localtax._split1+_localtax._split2+_localtax._split3);
        uint256 _tfee4 = tFee - _tfee0 - _tfee123;

        if (_isExcluded[burnAddress]) _tOwned[burnAddress] = _tOwned[burnAddress] + _tfee0;
        if (_isExcluded[address(this)]) _tOwned[address(this)] = _tOwned[address(this)] + _tfee123;

        emit Transfer(sender, burnAddress, _tfee0);
        emit Transfer(sender, address(this), _tfee123);

        return _tfee4;
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }
    
    function _getValues(uint256 tAmount, uint256 type_) private view returns (uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount, type_);
        uint256 currentRate =  _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, currentRate);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee);
    }

    function _getTValues(uint256 tAmount, uint256 type_) private view returns (uint256, uint256) {
        uint256 tFee = (tAmount * _governingTaxes[type_]._totalTaxPercent) / (100);
        uint256 tTransferAmount = tAmount - tFee;
        return (tTransferAmount, tFee);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount * (currentRate);
        uint256 rFee = tFee * (currentRate);
        uint256 rTransferAmount = rAmount - rFee;
        return (rAmount, rTransferAmount, rFee);
    }

	function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / (tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function manualswap() external onlyOwner() {
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }
    
    function manualsend(uint256 type_) external onlyOwner() {
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance, type_);
    }
}