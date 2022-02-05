/**
 *Submitted for verification at BscScan.com on 2022-02-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-28
*/

/*

TG:https://t.me/inuXV2official
WEB:https://inux.cc/





*/

pragma solidity 0.8.11;
// SPDX-License-Identifier: None
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
    function _msgSender() internal view virtual returns (address) {return msg.sender;}
    function _msgData() internal view virtual returns (bytes calldata) {return msg.data;}
}
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {_setOwner(_msgSender());}
    function owner() public view virtual returns (address) {return _owner;}
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0),"Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }
    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
interface IDexFactory {
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
    event Swap(address indexed sender, uint amount0In, uint amount1In, uint amount0Out, uint amount1Out, address indexed to);
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
interface IDexRouter {function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountETH);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}

contract BigKing is Context, IERC20, Ownable {
    IDexRouter public immutable router;
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) public _isExcludedFromTxLimits;
    mapping (address => bool) private _isExcludedFromRewards;
    address[] private _excluded;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1 * 10**9 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    string private _name = "BigKing";
    string private _symbol = "$BIGK";
    uint8 private _decimals = 18;

    uint256 public feeForLiquidity =    2;
    uint256 public feeForMarketing =    14;
    uint256 public feeForTeam =         2;
    uint256 public feeForReflections =  0;
    uint256 public feeDenominator =     100;
    uint256 public sellFeeMultiplier = 2500;
    uint256 public sellFeeDivisor = 1000;
    uint256 public maxTxAmount = _tTotal / 100;
    uint256 public maxWallet = _tTotal / 50;
    uint256 public launchedAt = 0;
    uint256 public blocksSinceLaunch = 0;
    
    uint256 private _tFeeTotal;
    uint256 private _totalFees = _liquidityFee + _taxFee;
    uint256 private _taxFee = feeForReflections;
    uint256 private _liquidityFee = feeForLiquidity + feeForMarketing + feeForTeam;
    uint256 private _previousLiquidityFee = _liquidityFee;
    uint256 private _previousTaxFee = _taxFee;
    bool private isSell = false;
    
    address payable public marketingWallet;
    address public immutable pcs2BNBPair;
    address[] public pairs;
    
    bool private inSwap;
    bool private swapEnabled = true;
    address payable private teamWallet;
    uint256 private swapThreshold = _tTotal / 2000;
    uint256 private maxSwapAmount =  _tTotal / 200;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    
    constructor (){
        _rOwned[_msgSender()] = _rTotal;
        router = IDexRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pcs2BNBPair = IDexFactory(router.factory()).createPair(router.WETH(), address(this));
        pairs.push(pcs2BNBPair);
        _approve(address(this), address(router), ~uint256(0));
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromTxLimits[owner()] = true;
        _isExcludedFromTxLimits[address(this)] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

/////////// Basic functions that will always be needed, but never modified  //////////////////////////////////////
    function name() public view returns (string memory) {return _name;}
    function symbol() public view returns (string memory) {return _symbol;}
    function decimals() public view returns (uint8) {return _decimals;}
    function totalSupply() public view override returns (uint256) {return _tTotal;}
    function isExcludedFromReward(address account) public view returns (bool) {return _isExcludedFromRewards[account];}
    function isExcludedFromFee(address account) public view returns(bool) {return _isExcludedFromFee[account];}
    function totalFees() public view returns (uint256) {return _tFeeTotal;}
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
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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
    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcludedFromRewards[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,,) = _getValues(tAmount);
        _rOwned[sender] -= rAmount;
        _rTotal -= rAmount;
        _tFeeTotal += tAmount;
    }
    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {(uint256 rAmount,,,,,) = _getValues(tAmount);return rAmount;} 
        else {(,uint256 rTransferAmount,,,,) = _getValues(tAmount);return rTransferAmount;}
    }
    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount / currentRate;
    }
    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }
    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount - tFee - tLiquidity;
        return (tTransferAmount, tFee, tLiquidity);
    }
    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rLiquidity = tLiquidity * currentRate;
        uint256 rTransferAmount = rAmount - rFee - rLiquidity;
        return (rAmount, rTransferAmount, rFee);
    }
    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }
    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply -= _rOwned[_excluded[i]];
            tSupply -= _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
/////////// Basic functions that will always be needed, but never modified  //////////////////////////////////////


/////////// Including in or excluding from fees, txLimits and rewards (only the dev can do this) ////////////////////
    function excludeFromReward(address account) public onlyOwner() {
        require(!_isExcludedFromRewards[account], "Account is already excluded");
        if(_rOwned[account] > 0) {_tOwned[account] = tokenFromReflection(_rOwned[account]);}
        _isExcludedFromRewards[account] = true;
        _excluded.push(account);
    }
    function includeInReward(address account) external onlyOwner() {
        require(_isExcludedFromRewards[account], "Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcludedFromRewards[account] = false;
                _excluded.pop();
                break;
            }
        }
    }
    function excludeFromFee(address account) public onlyOwner {_isExcludedFromFee[account] = true;}
    function includeInFee(address account) public onlyOwner {_isExcludedFromFee[account] = false;}
    function excludeFromTxLimits(address account) public onlyOwner {_isExcludedFromTxLimits[account] = true;}
    function includeInTxLimits(address account) public onlyOwner {_isExcludedFromTxLimits[account] = false;}
/////////// Including in or excluding from fees, txLimits and rewards (only the dev can do this) ////////////////////

/////////// Manage fees, txLimits and swapSettings (only the dev can do this) ///////////////////////////////////////
    function setBuyFees(uint256 reflectionsFee, uint256 liquidityFee, uint256 marketingFee, uint256 teamFee, uint256 newFeeDenominator) external onlyOwner() {
        feeForLiquidity =    liquidityFee;
        feeForMarketing =    marketingFee;
        feeForTeam =         teamFee;
        feeForReflections =  reflectionsFee;
        feeDenominator =     newFeeDenominator;
        _taxFee = feeForReflections;
        _liquidityFee = feeForLiquidity + feeForMarketing + feeForTeam;
        _totalFees = _liquidityFee + _taxFee; 
        _previousLiquidityFee = _liquidityFee;
        _previousTaxFee = _taxFee;
        require(_totalFees <= feeDenominator / 5, "Maximum buy fees are 20%");
    }

    function setSellFeeMultiplier(uint256 multiplier, uint256 divisor) external onlyOwner() {
        sellFeeMultiplier = multiplier;
        if(blocksSinceLaunch < 28800){
            sellFeeDivisor = 1000;
        } else {
            sellFeeDivisor = divisor;
        }
        require(sellFeeMultiplier * _totalFees / sellFeeDivisor <= feeDenominator / 4 , "Can not set sellFee higher than 25%");
    }

    function changeMarketingWallet(address payable _newMarketingWallet) public onlyOwner {
        require(_newMarketingWallet != address(0), "MarketingWallet can not be the zero address");
        marketingWallet = _newMarketingWallet;
    }

    function changeTeamWallet(address payable _newTeamWallet) public onlyOwner {
        require(_newTeamWallet != address(0), "TeamWallet can not be the zero address");
        teamWallet = _newTeamWallet;
    }


    function setMaxTxPerThousand(uint256 maxTxPerThousand) external onlyOwner() {
        maxTxAmount = _tTotal * maxTxPerThousand / 1000;
        require(maxTxAmount >= _tTotal / 200, "Max Transaction can't be lower than 0.5% of total Supply");
    }
    function setMaxWalletInThousands(uint256 maxWalletPerThousand) external onlyOwner() {
        maxWallet = _tTotal * maxWalletPerThousand / 1000;
        require(maxTxAmount >= _tTotal / 33, "Max Wallet can't be lower than 3% of total Supply");
    }

    function setSwapSettings(bool _enabled, uint256 newSwapThreshold, uint256 newMaxSwapAmount) public onlyOwner() {
        swapEnabled = _enabled;
        swapThreshold = newSwapThreshold * 10**18;
        maxSwapAmount = newMaxSwapAmount * 10**18;
    }
/////////// Manage fees, txLimits and swapSettings (only the dev can do this) ///////////////////////////////////////


/////////// Calculating and distributing of fees (only the contract can execute these functions) ////////////////////
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - (rFee);
        _tFeeTotal = _tFeeTotal + (tFee);
    }
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {return _amount * _taxFee / feeDenominator;}
    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {return _amount * _liquidityFee / feeDenominator;}
    function isThisASell(address sender, address recipient) internal {
        address[] memory liqPairs = pairs;
        for (uint256 i = 0; i < liqPairs.length; i++) {
            if (sender == liqPairs[i] ) {
            isSell = false;
            return;
		    }
        }
        for (uint256 i = 0; i < liqPairs.length; i++) {
            if (recipient == liqPairs[i]) {
                isSell = true;
			    return;
		    }
        }
        isSell = false;
        return;
    }
    function _takeFeeForLiquidityAndMarketing(uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity * currentRate;
        _rOwned[address(this)] += rLiquidity;
        if(_isExcludedFromRewards[address(this)])
            _tOwned[address(this)] += tLiquidity;
    }
    function removeAllFee() private {
        if(_taxFee == 0 && _liquidityFee == 0) return;
        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;
        _taxFee = 0;
        _liquidityFee = 0;
    }
    function restoreAllFee() private {_taxFee = _previousTaxFee; _liquidityFee = _previousLiquidityFee;}
    function applySellFeeMultiplier() internal {
        blocksSinceLaunch = block.number - launchedAt;
        if(blocksSinceLaunch < 28800){
                sellFeeMultiplier = 2500 - (1000 * blocksSinceLaunch / 28800);
        } else if(blocksSinceLaunch < 57600){
            sellFeeMultiplier = 1500 * sellFeeDivisor / 1000;
        }    
        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;
        _taxFee *= sellFeeMultiplier / sellFeeDivisor;
        _liquidityFee *= sellFeeMultiplier / sellFeeDivisor;
    }

    function launched() internal view returns (bool) {return launchedAt != 0;}
    function launch() internal {launchedAt = block.number;}

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        if (!launched() && to == pcs2BNBPair) {
            //require(_isExcludedFromTxLimits[from] == true, "Only someone without txlimit can be the first to add liquidity.");
            launch();
        }

        isThisASell(from, to);

        if(!_isExcludedFromTxLimits[from] &&  !_isExcludedFromTxLimits[to]) {
            require(amount <= maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            if(!isSell){
                require(amount + balanceOf(to) <= maxWallet, "Exceeds maxWallet");
            }
        }

        if (shouldSwapBack()) {swapAndLiquify();}

        bool takeFee = true;

        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }

        _tokenTransfer(from,to,amount,takeFee);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(!takeFee){
            removeAllFee();
        } else if(isSell) {
            applySellFeeMultiplier();
        }       
        if (_isExcludedFromRewards[sender] && !_isExcludedFromRewards[recipient]) {_transferFromExcluded(sender, recipient, amount);}
        else if (!_isExcludedFromRewards[sender] && _isExcludedFromRewards[recipient]) {_transferToExcluded(sender, recipient, amount);} 
        else if (!_isExcludedFromRewards[sender] && !_isExcludedFromRewards[recipient]) {_transferStandard(sender, recipient, amount);} 
        else if (_isExcludedFromRewards[sender] && _isExcludedFromRewards[recipient]) {_transferBothExcluded(sender, recipient, amount);} 
        else {_transferStandard(sender, recipient, amount);}
        
        if(!takeFee || isSell)
            restoreAllFee();
    }
    function shouldSwapBack() internal view returns (bool) {
        return launched() &&
        msg.sender != pcs2BNBPair &&
        !inSwap &&
        swapEnabled &&
        balanceOf(address(this)) >= swapThreshold;
    }
    function swapAndLiquify() private lockTheSwap {
        uint256 contractBalance = balanceOf(address(this));
        if(contractBalance > maxSwapAmount){
            contractBalance = maxSwapAmount;
            }
        uint256 amountToLiquidity = contractBalance * feeForLiquidity / _liquidityFee / 2;
        uint256 amountToSwapForBNB = contractBalance - amountToLiquidity;
        
        if(allowance(address(this), address(router)) < amountToSwapForBNB) {_approve(address(this), address(router), ~uint256(0));}
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwapForBNB,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amountBNB = address(this).balance;
        uint256 onePercentOfTax = amountBNB / (_liquidityFee - (feeForLiquidity/2));
        uint256 marketingBNB = onePercentOfTax * feeForMarketing; 
        payable(marketingWallet).transfer(marketingBNB);                      
        uint256 amountBNBLiquidity = address(this).balance;                   
		router.addLiquidityETH{value: amountBNBLiquidity}(
            address(this),
            amountToLiquidity,
            0,
            0,
            address(owner()),
            block.timestamp);
        payable(teamWallet).transfer(address(this).balance);
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - (rAmount);
        _rOwned[recipient] = _rOwned[recipient] + (rTransferAmount);
        _takeFeeForLiquidityAndMarketing(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - (rAmount);
        _tOwned[recipient] = _tOwned[recipient] + (tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient] + (rTransferAmount);           
        _takeFeeForLiquidityAndMarketing(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - (tAmount);
        _rOwned[sender] = _rOwned[sender] - (rAmount);
        _rOwned[recipient] = _rOwned[recipient] + (rTransferAmount);   
        _takeFeeForLiquidityAndMarketing(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - (tAmount);
        _rOwned[sender] = _rOwned[sender] - (rAmount);
        _tOwned[recipient] = _tOwned[recipient] + (tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient] + (rTransferAmount);        
        _takeFeeForLiquidityAndMarketing(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    
    receive() external payable {}
/////////// Calculating and distributing of fees (only the contract can execute these functions) ////////////////////

// for Jeets
}