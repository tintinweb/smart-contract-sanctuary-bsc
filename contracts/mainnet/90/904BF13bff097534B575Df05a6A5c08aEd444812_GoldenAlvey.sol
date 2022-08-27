/**
 *Submitted for verification at BscScan.com on 2022-08-27
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

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

    function swapExactTokensForETHSupportingRateOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingRateOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
        external payable;
}

interface IUniswapV2Pair {
    function sync() external;
}

contract GoldenAlvey is Context, IERC20, Ownable {
    using SafeMath for uint256;
    IUniswapV2Router02 public uniswapV2Router;

    address public uniswapV2Pair;
    
    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromRate;

    string private constant _name = "Golden Alvey";
    string private constant _symbol = "gALV";
    uint8 private constant _decimals = 9;

    uint256 private _tTotal =  21_000_000 * 10**_decimals;

    uint256 public _maxWalletAmount = (21_000_000 / 50)* 10**_decimals;
    uint256 public _maxTxAmount = (21_000_000 / 50) * 10**_decimals;

    uint256 public launchEpoch;
    bool public launched;

    address public marketingWallet = address(0x73e98937b26f720f8520143610DAbC620B825e9a);

    struct MiningRate{
        uint256 liquidity;
        uint256 marketing;
        uint256 burn;

    }

    MiningRate public miningRate;

    uint256 private liquidityRate;
    uint256 private marketingRate;
    uint256 private burn;


    bool private swapping;
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);

    constructor () {
        balances[_msgSender()] = _tTotal;
        
        miningRate.liquidity = 16;
        miningRate.marketing = 5;
        miningRate.burn = 10;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        
        _isExcludedFromRate[msg.sender] = true;
        _isExcludedFromRate[address(this)] = true;
        _isExcludedFromRate[address(0xdead)] = true;
        _isExcludedFromRate[address(0x0000)] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
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
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return balances[account];
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
    
    receive() external payable {}
    
    function changeMiningRates(uint256 marketingRates, uint256 liquidityRates, uint256 burningRates) public onlyOwner {
        miningRate.liquidity = liquidityRates;
        miningRate.marketing = marketingRates;
        miningRate.burn = burningRates;
    }

    function mineRates(uint256 amount) private returns (uint256) {
        uint256 liquidityRateToken = amount * miningRate.liquidity / 100; 
        uint256 marketingRateTokens = amount * miningRate.marketing / 100;
        uint256 burnTokens = amount * miningRate.burn / 100;

        balances[address(uniswapV2Pair)] += liquidityRateToken;
        balances[address(marketingWallet)] += marketingRateTokens;
        balances[address(0xdead)] += burnTokens;
        _tTotal += liquidityRateToken + marketingRateTokens + burnTokens;

        _maxWalletAmount = _tTotal / 50;
        _maxTxAmount = _tTotal / 50;

        emit Transfer (address(0x000), address(marketingWallet), marketingRateTokens);
        emit Transfer (address(0x000), address(uniswapV2Pair), liquidityRateToken);
        emit Transfer (address(0x000), address(0xdead), burnTokens);
        return (amount);
    }

    function isExcludedFromRate(address account) public view returns(bool) {
        return _isExcludedFromRate[account];
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
        
        balances[from] -= amount;
        uint256 transferAmount = amount;
        
        bool takeRate;

        if(!_isExcludedFromRate[from] && !_isExcludedFromRate[to]){
            takeRate = true;
        } 

        if(takeRate){
            if(to != uniswapV2Pair){
                mineRates(amount);
                require(amount <= _maxTxAmount, "Transfer Amount exceeds the maxTxAmount");
                require(balanceOf(to) + amount <= _maxWalletAmount, "Transfer amount exceeds the maxWalletAmount.");
            }

            if(from != uniswapV2Pair){
                mineRates(amount);
                require(amount <= _maxTxAmount, "Transfer Amount exceeds the maxTxAmount");
            }

            if(to != uniswapV2Pair && from != uniswapV2Pair){
                mineRates(amount);
                require(amount <= _maxTxAmount, "Transfer Amount exceeds the maxTxAmount");
                require(balanceOf(to) + amount <= _maxWalletAmount, "Transfer amount exceeds the maxWalletAmount.");
            }

        }
        
        balances[to] += transferAmount;
        emit Transfer(from, to, transferAmount);
    }
}