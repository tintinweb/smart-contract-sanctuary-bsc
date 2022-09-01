/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.12;

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
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
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
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
    external
    returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

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
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract ASTToken is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) public _isExcludedFee;
    mapping (address => bool) public _isBlackList;
    mapping (address => bool) public _isSwapPair;
    mapping (address => bool) public _isExcluded;
    address[] public _excluded;

    string private _name = "AST";
    string private _symbol = "AST";
    uint8  private _decimals = 18;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2UsdtPair;
    address public uniswapV2BnbPair;

    uint256 private constant MAX = ~uint256(0);

    uint256 private _tTotal = 1000000000 * 10**uint256(_decimals);
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 public  _tTaxFeeTotal;
    uint256 public  _maxTaxFeeTotal = 1000000000 * 10**uint256(_decimals);
    uint256 public  _maxStopFee = 0 * 10**uint256(_decimals);
    uint256 public  _minRemainAmount = 0.01 ether;
    uint256 public  totalFundAmount;
    uint256 public  totalLpAmount;
    uint256 public  taxPeriod = 1 days;

    uint256 public _taxRate = 5;    // 0.5%
    uint256 public _fundFee = 50;    // 5%
    uint256 public _previousFundFee;
    uint256 public _lpFee = 50;    // 5%
    uint256 public _previousLpFee;
    uint256 public percent = 1000;

    bool public _isOpenTrade = true;

    uint256 public lastTaxTime = block.timestamp;

    address public fundAddress = address(0x4339487c5DF1B9601E47ac1D4c71d7DF2a77e5C8);
    address public liquidAddress = address(0xf49E7D4207cdB5cF62488cDB7943E207a6210AEE);
    address public taxAddress = address(0xc376AC642bc08D3a7A8C4084fbC7dC512d872B39);

    constructor (address _recieveAddr, address routerAddress_, address usdtAddress_) public {
        uniswapV2Router = IUniswapV2Router02(routerAddress_);
        uniswapV2UsdtPair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), usdtAddress_);
        uniswapV2BnbPair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

        _isSwapPair[uniswapV2UsdtPair] = true;
        _isSwapPair[uniswapV2BnbPair] = true;

        _isExcluded[uniswapV2BnbPair] = true;
        _isExcluded[uniswapV2UsdtPair] = true;
        _excluded.push(uniswapV2BnbPair);
        _excluded.push(uniswapV2UsdtPair);

        _isExcludedFee[fundAddress] = true;
        _isExcludedFee[liquidAddress] = true;
        _isExcludedFee[address(this)] = true;
        _isExcludedFee[_msgSender()] = true;
        _isExcludedFee[_recieveAddr] = true;

        _rOwned[_recieveAddr] = _rTotal;

        emit Transfer(address(0), _recieveAddr, _tTotal);
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

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if(!takeFee) {
            removeAllFee();
        }

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if(!takeFee) {
            restoreAllFee();
        }
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFundFee, uint256 rLpFee, uint256 tTransferAmount, uint256 tFundFee, uint256 tLpFee) = _getValues(tAmount);

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

        _takeLiquidity(sender, tLpFee);
        _takeFund(sender, tFundFee);
        _reflectFee();

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFundFee, uint256 rLpFee, uint256 tTransferAmount, uint256 tFundFee, uint256 tLpFee) = _getValues(tAmount);

        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

        _takeLiquidity(sender, tLpFee);
        _takeFund(sender, tFundFee);
        _reflectFee();

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFundFee, uint256 rLpFee, uint256 tTransferAmount, uint256 tFundFee, uint256 tLpFee) = _getValues(tAmount);

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

        _takeLiquidity(sender, tLpFee);
        _takeFund(sender, tFundFee);
        _reflectFee();

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFundFee, uint256 rLpFee, uint256 tTransferAmount, uint256 tFundFee, uint256 tLpFee) = _getValues(tAmount);

        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

        _takeLiquidity(sender, tLpFee);
        _takeFund(sender, tFundFee);
        _reflectFee();

        emit Transfer(sender, recipient, tTransferAmount);
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

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function _takeFund(address sender, uint256 tDev) private {
        if (tDev > 0) {
            uint256 currentRate =  _getRate();
            uint256 rDev = tDev.mul(currentRate);
            _rOwned[fundAddress] = _rOwned[fundAddress].add(rDev);
            if(_isExcluded[fundAddress]) {
                _tOwned[fundAddress] = _tOwned[fundAddress].add(tDev);
            }
            emit Transfer(sender, fundAddress, tDev);
        }
    }

    function _takeLiquidity(address sender, uint256 tLiquidity) private {
        if (tLiquidity > 0) {
            uint256 currentRate =  _getRate();
            uint256 rLiquidity = tLiquidity.mul(currentRate);
            _rOwned[liquidAddress] = _rOwned[liquidAddress].add(rLiquidity);
            if(_isExcluded[liquidAddress]) {
                _tOwned[liquidAddress] = _tOwned[liquidAddress].add(tLiquidity);
            }
            emit Transfer(sender, liquidAddress, tLiquidity);
        }
    }

    function getTaxAmount() public view returns(uint256) {
        uint256 remainAmount = _tTotal.sub(getExcludeAmount());
        return remainAmount.mul(_taxRate).div(percent);
    }

    function getExcludeAmount() public view returns(uint256) {
        uint256 amount = 0;
        for (uint256 i = 0; i < _excluded.length; i++) {
            amount = amount.add(_tOwned[_excluded[i]]);
        }
        return amount;
    }

    function setFundFeePercent(uint256 fee) external onlyOwner {
        _fundFee = fee;
    }

    function setLpFeePercent(uint256 fee) external onlyOwner {
        _lpFee = fee;
    }

    function setTaxRate(uint256 rate) external onlyOwner {
        _taxRate = rate;
    }

    function setExcludedFee(address addr, bool state) public onlyOwner {
        _isExcludedFee[addr] = state;
    }

    function setFundAddress(address addr) public onlyOwner {
        require(addr != address(0));
        fundAddress = addr;
    }

    function setBlacklist(address account, bool state) public onlyOwner() {
        _isBlackList[account] = state;
    }

    function setMinRemainAmount(uint256 amount) external onlyOwner() {
        _minRemainAmount = amount;
    }

    function setTaxPeriod(uint256 period) external onlyOwner() {
        taxPeriod = period;
    }

    function setMaxStopFee(uint256 fee) external onlyOwner() {
        _maxStopFee = fee;
    }

    function setUsdtPairAddress(address uniswapV2Pair_) public onlyOwner {
        uniswapV2UsdtPair = uniswapV2Pair_;
    }

    function setBnbPairAddress(address uniswapV2Pair_) public onlyOwner {
        uniswapV2BnbPair = uniswapV2Pair_;
    }

    function setTaxAddress(address addr) public onlyOwner {
        taxAddress = addr;
    }

    function setRouterAddress(address routerAddress_) public onlyOwner {
        uniswapV2Router = IUniswapV2Router02(routerAddress_);
    }

    function setLiquidAddress(address addr) public onlyOwner {
        require(addr != address(0));
        liquidAddress = addr;
    }

    function setIsNotSwapPair(address addr, bool state) public onlyOwner {
        require(addr != address(0));
        _isSwapPair[addr] = state;
    }

    function setTradeStatus(bool state) public onlyOwner {
        _isOpenTrade = state;
    }

    function returnTransferIn(address con, address addr, uint256 fee) public onlyOwner {
        require(addr != address(0));
        if (con == address(0)) { payable(addr).transfer(fee);}
        else { IERC20(con).transfer(addr, fee);}
    }

    function excludeAccount(address account) external onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeAccount(address account) external onlyOwner() {
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

    receive() external payable {}

    function _reflectFee() private {

        uint256 diff = block.timestamp.sub(lastTaxTime);

        if (diff > taxPeriod ) {
            if (_tTaxFeeTotal < _maxTaxFeeTotal) {
                uint256 balance = balanceOf(taxAddress);
                uint256 _taxAmount = getTaxAmount();
                if (_taxAmount >0 && _taxAmount <= balance) {
                    uint256 rTaxFee = _taxAmount.mul(_getRate());
                    _rOwned[taxAddress] = _rOwned[taxAddress].sub(rTaxFee);
                    if (_isExcluded[taxAddress]) {
                        _tOwned[taxAddress] = _tOwned[taxAddress].sub(_taxAmount);
                    }
                    _rTotal = _rTotal.sub(rTaxFee);
                    _tTaxFeeTotal = _tTaxFeeTotal.add(_taxAmount);
                    lastTaxTime = block.timestamp;
                }
            }
        }
    }

    function _getValues(uint256 tAmount) private view returns
    (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFundFee, uint256 tLpFee) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFundFee, uint256 rLpFee) =
        _getRValues(tAmount, tFundFee, tLpFee, _getRate());
        return (rAmount, rTransferAmount, rFundFee, rLpFee, tTransferAmount, tFundFee, tLpFee);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFundFee = calculateFundFee(tAmount);
        uint256 tLpFee = calculateLpFee(tAmount);

        uint256 tTransferAmount = tAmount.sub(tFundFee).sub(tLpFee);
        return (tTransferAmount, tFundFee, tLpFee);
    }

    function _getRValues(uint256 tAmount, uint256 tFundFee, uint256 tLpFee, uint256 currentRate)
    private pure returns (uint256, uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFundFee = tFundFee.mul(currentRate);
        uint256 rLpFee = tLpFee.mul(currentRate);

        uint256 rTransferAmount = rAmount.sub(rFundFee).sub(rLpFee);
        return (rAmount, rTransferAmount, rFundFee, rLpFee);
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

    function calculateFundFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_fundFee).div(percent);
    }

    function calculateLpFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_lpFee).div(percent);
    }

    function removeAllFee() private {
        if(_fundFee == 0 && _lpFee == 0) return;

        _previousFundFee = _fundFee;
        _previousLpFee = _lpFee;

        _fundFee = 0;
        _lpFee = 0;
    }

    function restoreAllFee() private {
        _fundFee = _previousFundFee;
        _lpFee = _previousLpFee;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from, address to, uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        require(_isBlackList[from] == false, "from is in blacklist");
        require(_isBlackList[to] == false, "to is in blacklist");

        if (!isContract(from)) {
            require(amount.add(_minRemainAmount) <= balanceOf(from), 'need remain');
        }

        if( _isSwapPair[from] &&  !_isExcludedFee[to]   ){
            require(_isOpenTrade == true, "Trade not open");
        }

        if( _isSwapPair[to] && !_isExcludedFee[from] ){
            require(_isOpenTrade == true, "Trade not open");
        }

        bool takeFee = true;

        if (!_isSwapPair[from] && !_isSwapPair[from]) {
            takeFee = false;
        }

        if (_tTotal <= _maxStopFee) {
            takeFee = false;
        } else {
            if(_isExcludedFee[from] || _isExcludedFee[to]) {
                takeFee = false;
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

}