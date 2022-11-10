/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

// SPDX-License-Identifier: Licensed
   

pragma solidity ^0.8.6;

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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract Resister  is Context, IERC20, Ownable {
    using SafeMath for uint256;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;
   
    string private constant _name = "Resister Inu";
    string private constant _symbol = "Resister";
    uint8 private constant _decimals = 9;
    uint256 private _tTotal = 1000000 * 10**_decimals;

    uint256 public _maxWalletAmount = 40000* 10**_decimals;
    uint256 public _maxTxAmount = 40000* 10**_decimals;
    uint256 public swapTokenAtAmount = 40000 * 10**_decimals;

    struct BuyFees{
        uint256 marketing;
        uint256 liquidity;
    }

    struct SellFees{
        uint256 marketing;
        uint256 liquidity;
    }

    BuyFees public buyFee;
    SellFees public sellFee;

    uint256 private marketingFee;
    uint256 private liquidityFee;

    address private marketingWallet = address(0x043931ab6F4595f30a80F6fCd481A64FD3D64d04);
    address private liquidityReceiver = address(0x043931ab6F4595f30a80F6fCd481A64FD3D64d04);
    
    uint256 public _buyCooldown = 0 minutes;
    mapping (address => uint256) private _lastBuy;
    
    bool private swapping;
    
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);
        
    constructor () {
        _tOwned[_msgSender()] = _tTotal;
        
        buyFee.marketing = 1;
        buyFee.liquidity = 0;

        sellFee.marketing = 2;
        sellFee.liquidity = 0;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[marketingWallet] = true;
        
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
    
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    
    receive() external payable {}
    
    function _getValues(uint256 amount, address from) private returns (uint256) {
        uint256 marketingFeeToken = amount * marketingFee / 100; 
        uint256 liquidityFeeToken = amount * liquidityFee / 100; 
        _tOwned[address(this)] += marketingFeeToken + liquidityFeeToken;
        emit Transfer (from, address(this), marketingFeeToken + liquidityFeeToken);
        return (amount - marketingFeeToken- liquidityFeeToken);
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setBuyFees(uint256 newMarketingFee, uint256 newLiquidityFee) public onlyOwner {
        buyFee.marketing = newMarketingFee;
        buyFee.liquidity = newLiquidityFee;
    }

    function setSellFees(uint256 newMarketingFee, uint256 newLiquidityFee) public onlyOwner {
        sellFee.marketing = newMarketingFee;
        sellFee.liquidity = newLiquidityFee;
    }

    function setMaxTxPercent(uint256 newMaxTxPercent) public onlyOwner {
        require(newMaxTxPercent >= 1, "Can't set maxTxPercent to 0%");
        _maxTxAmount = _tTotal.mul(newMaxTxPercent).div(10**2);
    }

    function setMaxWalletPercent(uint256 newMaxWalletPercent) public onlyOwner {
        require(newMaxWalletPercent >= 1, "Can't set maxWalletPercent to 0%");
        _maxWalletAmount = _tTotal.mul(newMaxWalletPercent).div(10**2);    
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        if (from == uniswapV2Pair) {
            require (_lastBuy[to] + _buyCooldown < block.timestamp, "Must wait til after coooldown to buy");
            _lastBuy[to] = block.timestamp;
        }
        
        _tOwned[from] -= amount;
        uint256 transferAmount = amount;
        
        bool takeFee;

        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
            takeFee = true;
        } 

        if(takeFee){
            if(to != uniswapV2Pair){
                require(amount <= _maxTxAmount, "Transfer Amount exceeds the maxTxAmount");
                require(balanceOf(to) + amount <= _maxWalletAmount, "Transfer amount exceeds the maxWalletAmount.");
                _buyFee();
                 transferAmount = _getValues(amount, from);
            }

            if(from != uniswapV2Pair){
                require(amount <= _maxTxAmount, "Transfer Amount exceeds the maxTxAmount");
                _sellFee();
                transferAmount = _getValues(amount, from);

               if (balanceOf(address(this)) >= swapTokenAtAmount && !swapping) {
                    swapping = true;
                    uint256 sellTokens = swapTokenAtAmount;
                    swapAndSendToFee(sellTokens);
                    swapping = false;
              }
            }
        }
        
        _tOwned[to] += transferAmount;
        emit Transfer(from, to, transferAmount);
    }
    
    
    function swapAndSendToFee (uint256 tokens) private {
        uint256 ethToSend = swapTokensForEth(tokens);
        
        if (ethToSend > 0)
            payable(marketingWallet).transfer(ethToSend);
    }

    function swapAndLiquify() private {
        uint256 liquidityTokens = balanceOf (address(this)) * liquidityFee / (marketingFee + liquidityFee);
        uint256 half = liquidityTokens / 2;
        uint256 otherHalf = liquidityTokens - half;
        uint256 newBalance = swapTokensForEth(half);

        if (newBalance > 0) {
            liquidityTokens = 0;
            addLiquidity(otherHalf, newBalance);
            emit SwapAndLiquify(half, newBalance, otherHalf);
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private returns (uint256) {
        uint256 initialBalance = address(this).balance;
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
        return (address(this).balance - initialBalance);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        (,uint256 ethFromLiquidity,) = uniswapV2Router.addLiquidityETH {value: ethAmount} (
            address(this),
            tokenAmount,
            0,
            0,
            liquidityReceiver,
            block.timestamp
        );
        
        if (ethAmount - ethFromLiquidity > 0)
            payable(marketingWallet).transfer(ethAmount - ethFromLiquidity);
    }

    function _buyFee() private{
        marketingFee = buyFee.marketing;
        liquidityFee = buyFee.liquidity;
    }

    function _sellFee() private{
        marketingFee = sellFee.marketing;
        liquidityFee = sellFee.liquidity;
    }
}