/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

// SPDX-License-Identifier: Unlicensed
                                                                               
pragma solidity 0.8.17;

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
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// IERC20 interface 
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


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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
}

// SafeMath library
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract W3T is Context, IERC20, Ownable {

    using SafeMath for uint256;
   
    IUniswapV2Router02 public _uniswapV2Router; 
    address public _uniswapV2LiquidityPair; 
    
    string private _name     = "Web3 Task Token";
    string private _symbol   = "W3T";
    uint8  private _decimals = 18;
    
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;

    uint256 public reflectionFee = 2;
    uint256 public marketingFee = 1;
    uint256 private _totalTax = reflectionFee.add(marketingFee);
    uint256 private _previousTaxFee;

    address public marketingWallet = 0x73ba9C90e5EaE1ea9950094A9f8E20051a65d21C;

    uint256 public _maxTxAmount        = 300000000 * 10**18;  

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 300000000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _totalReflections; // Total reflections

    constructor () {
        _rOwned[_msgSender()] = _rTotal;
        
        // Exclude the owner and the contract from paying fees
        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(this)] = true;
        
        // Set up the uniswap V2 router
        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _uniswapV2LiquidityPair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        _uniswapV2Router = uniswapV2Router;
        
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function getTotalReflections() external view returns (uint256) {
        return _totalReflections;
    }
    
    function isExcludedFromFee(address account) external view returns(bool) {
        return _isExcludedFromFees[account];
    }
    
    function isExcludedFromReflection(address account) external view returns(bool) {
        return _isExcluded[account];
    }
    
    function excludeFromFee(address account) external onlyOwner() {
        _isExcludedFromFees[account] = true;
    }
    
    function includeInFee(address account) external onlyOwner() {
        _isExcludedFromFees[account] = false;
    }
    
    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }
    
    function removeAllFees() private {
        if(_totalTax == 0) return;
        
        _previousTaxFee = _totalTax;
        _totalTax = 0;
    }
    
    function restoreAllFees() private {
        _totalTax = _previousTaxFee;
    }
    
    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256) {
        uint256 tFee = tAmount.mul(_totalTax).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee);
        return (tTransferAmount, tFee);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee);
        return (rAmount, rTransferAmount, rFee);
    }


    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    
    function excludeFromReward(address account) external onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already included");
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
    
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        // Only the owner of this contract can bypass the max transfer amount
        if(from != owner() && to != owner()) {
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }

        // If any account belongs to _isExcludedFromFee account then remove the fee
        bool takeFee = !(_isExcludedFromFees[from] || _isExcludedFromFees[to]);

        // Remove fees completely from the transfer if either wallet are excluded
        if (!takeFee) {
            removeAllFees();
        }
        
        // Transfer the token amount from sender to receipient.
        _tokenTransfer(from, to, amount);
        
        // If we removed the fees for this transaction, then restore them for future transactions
        if (!takeFee) {
            restoreAllFees();
        }
        
    }
    
    function _tokenTransfer(address sender, address recipient, uint256 tAmount) private {
        // Calculate the values required to execute a transfer
        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount,) = _getRValues(tAmount, tFee, _getRate());
        
        // Transfer from sender to recipient
		if (_isExcluded[sender]) {
		    _tOwned[sender] = _tOwned[sender].sub(tAmount);
		}
		_rOwned[sender] = _rOwned[sender].sub(rAmount);
		
		if (_isExcluded[recipient]) {
            _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
		}
		_rOwned[recipient] = _rOwned[recipient].add(rTransferAmount); 
		
		if (tFee > 0) {
	    	uint256 marketingTokens = tFee.mul(marketingFee).div(_totalTax);
            uint256 reflectionTokens = tFee.mul(reflectionFee).div(_totalTax);

            // Reflect some of the taxed tokens 
    		_reflectTokens(reflectionTokens);
            
            // Take the rest of the taxed tokens for marketing wallet
            if(marketingTokens > 0) {
                _takeTokens(marketingTokens);
                emit Transfer(sender, marketingWallet, marketingTokens);
            }
		}
            
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectTokens(uint256 tFee) private {
        uint256 rFee = tFee.mul(_getRate());
        _rTotal = _rTotal.sub(rFee);
        _totalReflections = _totalReflections.add(tFee);
    }
    
    function _takeTokens(uint256 tTakeAmount) private {
        uint256 currentRate = _getRate();
        uint256 rTakeAmount = tTakeAmount.mul(currentRate);
        _rOwned[marketingWallet] = _rOwned[marketingWallet].add(rTakeAmount);
        if(_isExcluded[marketingWallet]) {
            _tOwned[marketingWallet] = _tOwned[marketingWallet].add(tTakeAmount);
        }
    }
   
    function reflect(uint256 tAmount) public {
        require(!_isExcluded[_msgSender()], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,) = _getValues(tAmount);
        _rOwned[_msgSender()] = _rOwned[_msgSender()].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _totalReflections = _totalReflections.add(tAmount);
    }

    function setTaxFeePercent(uint256 reflection, uint256 marketing) external onlyOwner() {
        reflectionFee = reflection;
        marketingFee = marketing;
        _totalTax = reflectionFee.add(marketingFee);
        require(_totalTax <= 7, "tax too high");
    }

    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
        _maxTxAmount = maxTxAmount;
        require(_maxTxAmount >= _tTotal.div(200), "value too low");
    }

    function setMarketingWallet(address _markWallet) external onlyOwner() {
        marketingWallet = _markWallet;
    }

}