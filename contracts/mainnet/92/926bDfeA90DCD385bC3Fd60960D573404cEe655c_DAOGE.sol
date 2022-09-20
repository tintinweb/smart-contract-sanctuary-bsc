/**
 *Submitted for verification at BscScan.com on 2022-09-20
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.16;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

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

}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "ZERO ADDRESS");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

contract DAOGE is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcludedFromMaxLimit;
    mapping (address => bool) public bonkList;
    
    uint256 private constant _tTotal = 1 * 10**9 * 10**18;
    uint256 private _taxFee = 3;
    
    string private constant _name = "DAOGE";
    string private constant _symbol = "DAOGE";
    uint8 private constant _decimals = 18;
    
    address payable private _feeAddress = payable(0x81eDC2648ceefdAd8d97604F7b838415cb4F9e91);

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    uint256 private _threshold = _tTotal.div(2000);
    uint256 private _maxGas = 7 gwei;
    
    bool public maxLimit = false;
    bool private inSwap = false;
    bool private feeSwap = true;

    event toggleMaxLimitEvent(bool _maxLimit);
    event excludeFromFeesEvent(address[] accounts, bool excluded);
    event excludeFromMaxLimitEvent(address[] accounts, bool excluded);
    event toggleFeeEvent(bool _feeSwap);
    event updateFeeAddressEvent(address _newFeeAddress);
    
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () {
        _tOwned[_msgSender()] = _tTotal;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_feeAddress] = true;

        emit Transfer(address(0x0000000000000000000000000000000000000000), _msgSender(), _tTotal);
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

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
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

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!bonkList[from], "bonked");

        _taxFee = 0;
        
        if (from != owner() && to != owner()) {
            if (maxLimit && !_isExcludedFromMaxLimit[from]) {
                require(amount <= _tTotal.div(200), "maxTx");
                require(tx.gasprice <= _maxGas, "maxGas");
            }    

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && from != uniswapV2Pair && feeSwap && contractTokenBalance > _threshold) {
                swapTokensForEth(_threshold);
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
            
            // buy tx
            if(from == uniswapV2Pair && to != address(uniswapV2Router)) {
                _taxFee = 3;
            }
    
            // sell tx
            if (to == uniswapV2Pair && from != address(uniswapV2Router)) {
                _taxFee = 3;
            }
            
            // excluded from fee + non trading tx
            if ((_isExcludedFromFee[from] || _isExcludedFromFee[to]) || (from != uniswapV2Pair && to != uniswapV2Pair)) {
                _taxFee = 0;
            }            
        }

        // execute the tx
        uint256 tax = amount.mul(_taxFee).div(100);
        uint256 remainder = amount.sub(tax);

        _tOwned[from] = _tOwned[from].sub(amount);
        _tOwned[to] = _tOwned[to].add(remainder);
        _tOwned[address(this)] = _tOwned[address(this)].add(tax);

        emit Transfer(from, to, amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
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
        
    function sendETHToFee(uint256 amount) private {
        _feeAddress.transfer(amount);
    }

    receive() external payable {}
 
    function toggleFee(bool _feeSwap) public onlyOwner {
        feeSwap = _feeSwap;
        emit toggleFeeEvent(_feeSwap);
    }

    function toggleMaxLimit(bool _maxLimit) public onlyOwner {
        maxLimit = _maxLimit;
        emit toggleMaxLimitEvent(_maxLimit);
    }

    function excludeFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = excluded;
        }
        emit excludeFromFeesEvent(accounts, excluded);
    }

    function excludeFromMaxLimit(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromMaxLimit[accounts[i]] = excluded;
        }
        emit excludeFromMaxLimitEvent(accounts, excluded);
    }

    function updateFeeAddress (address _newFeeAddress) public onlyOwner {
        _feeAddress = payable(_newFeeAddress);
        emit updateFeeAddressEvent(_newFeeAddress);
    }

    function updateMaxGas (uint256 _newMaxGas) public onlyOwner {
        require(_newMaxGas >= 5, "too low");
        _maxGas = _newMaxGas * 10**9;
    }

    function updateThreshold (uint256 _newThreshold) public onlyOwner {
        _threshold = _newThreshold * 10**18;
    }

    function updateBonkList(address[] calldata accounts, bool bonked) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            bonkList[accounts[i]] = bonked;
        }
    }

    function rescueTokens() external onlyOwner {
        // if autoETH harvesting disabled
        require(!feeSwap, "feeSwap not false");

        uint256 contractTokenBalance = balanceOf(address(this));
        _tOwned[address(this)] = _tOwned[address(this)].sub(contractTokenBalance);
        _tOwned[_feeAddress] = _tOwned[_feeAddress].add(contractTokenBalance);
    }

    function rescueETH() external onlyOwner {
        // if autoETH harvesting disabled
        require(!feeSwap, "feeSwap not false");

        uint256 contractETHBalance = address(this).balance;
        _feeAddress.transfer(contractETHBalance);
    }
}