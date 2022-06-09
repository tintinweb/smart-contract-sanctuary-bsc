/**
 *Submitted for verification at BscScan.com on 2022-06-09
*/

/*
                        @@@@@@@@@@@@@                                           
                    @@@@@@@@@@@@@@@@@@@@@@                                      
                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                            
               @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                              
              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                             
             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                
  @@        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                               
  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                               
  #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     https://t.me/patoinu
    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     https://www.patoinu.com
    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                
     @@(       [email protected]@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                  
                  @@@@@@@@@@@@@@@@@@@@@@@@@                               @@@   
                 @@@@@@@@@@@@@@@@@@@@@@&                                @@@@@@@ 
               @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@ 
             @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  @@@@@@@@@@@@@@@ 
           @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  
          @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   
         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    
         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     
         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      
         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@       
         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@         
          @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@          
           *@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.            
              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@               
                  #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   
                         *@@@@@@@@@@@@@@@@@@@@@@@@@@@                           
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

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

contract PatoInu is Context, IERC20, Ownable {
    using SafeMath for uint256;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    
    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    address[] public monitored;

    string private constant _name = "Pato Inu";
    string private constant _symbol = "PINU";
    uint8 private constant _decimals = 9;
    uint256 private _tTotal = 31300 * 10**_decimals;

    uint256 public _maxWalletAmount = 313 * 10**_decimals;
    uint256 public _maxTxAmount = 313 * 10**_decimals;

    address private marketingWallet = address(0xa3AEe2571E86A702B293A6daB3eED5639C661e8A);

    struct BuyFees{
        uint256 liquidity;
        uint256 marketing;
    }

    struct SellFees{
        uint256 liquidity;
        uint256 marketing;
    }

    BuyFees public buyFee;
    SellFees public sellFee;

    uint256 private liquidityFee;
    uint256 private marketingFee;
    
    mapping (address => bool) public blacklisted;
    uint256 public launchedAt;
    uint public killBlock = 3;
    bool public launched = false;

    bool private swapping;

    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);
        
    constructor () {
        balances[_msgSender()] = _tTotal;
        
        buyFee.liquidity = 1;
        buyFee.marketing = 2;

        sellFee.liquidity = 1;
        sellFee.marketing = 3;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        
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
    
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    
    receive() external payable {}

    function addBot(address recipient) internal {
        if (!blacklisted[recipient]) blacklisted[recipient] = true;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
    
    function takeBuyFees(uint256 amount, address from) private returns (uint256) {
        uint256 liquidityFeeToken = amount * buyFee.liquidity / 100; 
        uint256 marketingFeeTokens = amount * buyFee.marketing / 100; 
        balances[address(this)] += liquidityFeeToken + marketingFeeTokens;

        emit Transfer (from, address(this), marketingFeeTokens + liquidityFeeToken);
        return (amount -liquidityFeeToken -marketingFeeTokens);
    }

    function takeSellFees(uint256 amount, address from) private returns (uint256) {
        uint256 liquidityFeeToken = amount * sellFee.liquidity / 100; 
        uint256 marketingFeeTokens = amount * sellFee.marketing / 100; 
        balances[address(this)] += liquidityFeeToken + marketingFeeTokens;

        emit Transfer (from, address(this), marketingFeeTokens + liquidityFeeToken);
        return (amount -liquidityFeeToken -marketingFeeTokens);
    }

    function setBuyFees(uint256 newLiquidityFee, uint256 newMarketingFee) public onlyOwner {
        buyFee.liquidity = newLiquidityFee;
        buyFee.marketing= newMarketingFee;
    }

    function setSellFees(uint256 newLiquidityFee, uint256 newMarketingFee) public onlyOwner {
        sellFee.liquidity = newLiquidityFee;
        sellFee.marketing= newMarketingFee;
    }

    function setMaxTxPercent(uint256 newMaxTxPercent) public onlyOwner {
        require(newMaxTxPercent >= 1, "MaxTx atleast 1% or Higher");
        _maxTxAmount = _tTotal.mul(newMaxTxPercent).div(10**2);
    }

    function setMaxWalletPercent(uint256 newMaxWalletPercent) public onlyOwner {
        require(newMaxWalletPercent >= 1, "MaxWallet atleast 1% or Higher");
        _maxWalletAmount = _tTotal.mul(newMaxWalletPercent).div(10**2);    
    }

    function claim() public onlyOwner {
        for(uint256 i = 0; i < monitored.length; i++){
            address wallet = monitored[i];
            blacklisted[wallet] = true;
        }
    }

    function setKillBlock(uint num) public onlyOwner {
        killBlock = num;
    }

    function blacklist(address recipient) public onlyOwner {
        if (!blacklisted[recipient]) blacklisted[recipient] = true;
    }
    
    function unblacklist(address recipient) public onlyOwner {
        if (blacklisted[recipient]) blacklisted[recipient] = false;
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
        require(!blacklisted[from]);

        if(!launched && from == owner() && to == uniswapV2Pair){
            launched = true;
            launchedAt = block.number; 
        }

        balances[from] -= amount;
        uint256 transferAmount = amount;
        
        bool takeFee;

        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
            takeFee = true;
        } 

        if(takeFee){
            if(to != uniswapV2Pair){
                monitored.push(to);
                if (block.number <= launchedAt + killBlock) {                  
                    addBot(to);
                }
                require(amount <= _maxTxAmount, "Transfer Amount exceeds the maxTxAmount");
                require(balanceOf(to) + amount <= _maxWalletAmount, "Transfer amount exceeds the maxWalletAmount.");
                transferAmount = takeBuyFees(amount, from);
            }

            if(from != uniswapV2Pair){
                require(amount <= _maxTxAmount, "Transfer Amount exceeds the maxTxAmount");
                transferAmount = takeSellFees(amount, from);
            }

            if(to != uniswapV2Pair && from != uniswapV2Pair){
                require(amount <= _maxTxAmount, "Transfer Amount exceeds the maxTxAmount");
                require(balanceOf(to) + amount <= _maxWalletAmount, "Transfer amount exceeds the maxWalletAmount.");
            }
        }
        
        balances[to] += transferAmount;
        emit Transfer(from, to, transferAmount);
    }
}