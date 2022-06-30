/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

// SPDX-License-Identifier: MIT

/**
 ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄       ▄▄▄▄▄▄▄▄▄▄▄     ▄▄▄▄▄▄▄▄▄  
▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌     ▐░░░░░░░░░░░▌   ▐░░░░░░░░░▌ 
 ▀▀▀▀█░█▀▀▀▀  ▀▀▀▀█░█▀▀▀▀ ▐░█▀▀▀▀▀▀▀▀▀  ▀▀▀▀█░█▀▀▀▀       ▀▀▀▀▀▀▀▀▀█░▌  ▐░█░█▀▀▀▀▀█░▌
     ▐░▌          ▐░▌     ▐░▌               ▐░▌                    ▐░▌  ▐░▌▐░▌    ▐░▌
     ▐░▌          ▐░▌     ▐░█▄▄▄▄▄▄▄▄▄      ▐░▌                    ▐░▌  ▐░▌ ▐░▌   ▐░▌
     ▐░▌          ▐░▌     ▐░░░░░░░░░░░▌     ▐░▌           ▄▄▄▄▄▄▄▄▄█░▌  ▐░▌  ▐░▌  ▐░▌
     ▐░▌          ▐░▌     ▐░█▀▀▀▀▀▀▀▀▀      ▐░▌          ▐░░░░░░░░░░░▌  ▐░▌   ▐░▌ ▐░▌
     ▐░▌          ▐░▌     ▐░▌               ▐░▌          ▐░█▀▀▀▀▀▀▀▀▀   ▐░▌    ▐░▌▐░▌
     ▐░▌      ▄▄▄▄█░█▄▄▄▄ ▐░▌           ▄▄▄▄█░█▄▄▄▄      ▐░█▄▄▄▄▄▄▄▄▄  ▄▐░█▄▄▄▄▄█░█░▌
     ▐░▌     ▐░░░░░░░░░░░▌▐░▌          ▐░░░░░░░░░░░▌     ▐░░░░░░░░░░░▌▐░▌▐░░░░░░░░░▌ 
      ▀       ▀▀▀▀▀▀▀▀▀▀▀  ▀            ▀▀▀▀▀▀▀▀▀▀▀       ▀▀▀▀▀▀▀▀▀▀▀  ▀  ▀▀▀▀▀▀▀▀▀  
TiFi Token 2.0 - $TIFI 2.0
   Based on our long-term observations of the global real estate market, we now want to take the lead in the 
upcoming changes in the real estate investment market. We will be providing variety of real estate investment 
opportunities through blockchain technology. 

Token Basic Info:
Name: TiFi Token 2.0
Symbol: TIFI 2.0
Supply: 10,000,000
Telegram: https://t.me/TiFi_twozero
Website:  https://tifitwo.net

Tokenomics:

Buy Fees
3% Marketing Fee
3% Development Fee

Sell Fees
3% Marketing Fee
3% Development Fee

Other
3% Max Transaction
3% Max Wallet
*/

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

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
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

contract TiFiTokenTwoZero is Context, IERC20, Ownable {
    using SafeMath for uint256;
    IUniswapV2Router02 public uniswapV2Router;

    address public uniswapV2Pair;
    
    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;

    string private constant _name = "TiFi Token 2.0";
    string private constant _symbol = "TIFI 2.0";
    uint8 private constant _decimals = 18;
    uint256 private _tTotal =  10000000 * 10**_decimals;

    uint256 public _maxWalletAmount = 100001 * 10**_decimals;
    uint256 public _maxTxAmount = 100001 * 10**_decimals;
    uint256 public swapTokenAtAmount = 25000 * 10**_decimals;

    address public marketingWallet = address(0x391b9781a556423233cBC31e9e15e9224284E872);
    address public devWallet = address(0xD57586cb08F6216f9f84377e13F9C010349f473e);

    bool public blacklistMode;
    mapping (address => bool) public blacklisted;

    struct BuyFees{
        uint256 marketing;
        uint256 dev;
    }

    struct SellFees{
        uint256 marketing;
        uint256 dev;
    }

    BuyFees public buyFee;
    SellFees public sellFee;

    uint256 private marketingFee;
    uint256 private devFee;

    bool private swapping;
    uint256 public launchedAt;
    bool public launched;

    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);
        
    constructor () {
        balances[_msgSender()] = _tTotal;
        
        buyFee.marketing = 3;
        buyFee.dev = 3;

        sellFee.marketing = 11;
        sellFee.dev = 11;
        
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
    
    function excludeFromFee(address account, bool excluded) public onlyOwner {
        _isExcludedFromFee[account] = excluded;
    }

    function blacklistMultipleAccount(address[] memory account, bool isBlacklisted) public onlyOwner {
        for(uint256 i = 0; i < account.length; i++){
            address wallet = account[i];
            blacklisted[wallet] = isBlacklisted;
        }
    }

    function setBlacklistMode(bool enabled) public onlyOwner {
        blacklistMode = enabled;
    }

    function changeMaxTx(uint256 amount) public onlyOwner {
        require(amount >= 100000, "Can't set maxTx Below 1%");
        _maxTxAmount = amount * 10**_decimals;
    }

    function changeMaxWallet(uint256 amount) public onlyOwner {
        require(amount >= 100000, "Can't set maxWallet Below 1%");
        _maxWalletAmount = amount * 10**_decimals;
    }

    function changeBuyFee(uint256 MktFee, uint256 DevFee) public onlyOwner {
        require(MktFee + DevFee <= 20, "Can't change BuyFee above 20%");

        buyFee.marketing = MktFee;
        buyFee.dev = DevFee;
    }

    function changeSellFee(uint256 MktFee, uint256 DevFee) public onlyOwner {
        require(MktFee + DevFee <= 25, "Can't change SellFee above 20%");
        sellFee.marketing = MktFee;
        sellFee.dev = DevFee;
    }

    function chnageSwapTokenAtAmount(uint256 amount) public onlyOwner {
        swapTokenAtAmount = amount * 10**_decimals;
    }

    receive() external payable {}
    
    function takeBuyFees(uint256 amount, address from) private returns (uint256) {
        uint256 marketingFeeTokens = amount * buyFee.marketing / 100;
        uint256 devFeeToken = amount * buyFee.dev / 100;
        balances[address(this)] += marketingFeeTokens + devFeeToken;

        emit Transfer (from, address(this), marketingFeeTokens + devFeeToken);
        return (amount -marketingFeeTokens -devFeeToken);
    }

    function takeSellFees(uint256 amount, address from) private returns (uint256) {
        uint256 marketingFeeTokens = amount * sellFee.marketing / 100; 
        uint256 devFeeToken = amount * sellFee.dev / 100;
        balances[address(this)] += marketingFeeTokens + devFeeToken;

        emit Transfer (from, address(this), marketingFeeTokens + devFeeToken);
        return (amount -marketingFeeTokens -devFeeToken);
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

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        if(blacklistMode){
            require(!blacklisted[from], "Your address is blacklisted");
        }

        balances[from] -= amount;
        uint256 transferAmount = amount;
        
        bool takeFee;

        if(!launched && from == owner() && to == uniswapV2Pair){
            launched = true;
            launchedAt = block.timestamp; 
        }

        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
            takeFee = true;
        } 

        if(takeFee){
            if(to != uniswapV2Pair){
                require(amount <= _maxTxAmount, "Transfer Amount exceeds the maxTxAmount");
                require(balanceOf(to) + amount <= _maxWalletAmount, "Transfer amount exceeds the maxWalletAmount.");
                transferAmount = takeBuyFees(amount, from);
            }

            if(from != uniswapV2Pair){
                require(amount <= _maxTxAmount, "Transfer Amount exceeds the maxTxAmount");
                transferAmount = takeSellFees(amount, from);

               if (balanceOf(address(this)) >= swapTokenAtAmount && !swapping) {
                    swapping = true;
                    swapBack();
                    swapping = false;
              }
            }

            if(to != uniswapV2Pair && from != uniswapV2Pair){
                require(amount <= _maxTxAmount, "Transfer Amount exceeds the maxTxAmount");
                require(balanceOf(to) + amount <= _maxWalletAmount, "Transfer amount exceeds the maxWalletAmount.");
            }
        }
        
        balances[to] += transferAmount;
        emit Transfer(from, to, transferAmount);
    }
    
    
    function swapBack() private {
        uint256 contractBalance = swapTokenAtAmount;
        uint256 marketingTokens = contractBalance * (buyFee.marketing + sellFee.marketing) / (buyFee.marketing + sellFee.marketing + buyFee.dev + sellFee.dev);
        uint256 devTokens = contractBalance * (buyFee.dev + sellFee.dev) / (buyFee.marketing + sellFee.marketing + buyFee.dev + sellFee.dev);
        uint256 totalTokensToSwap = marketingTokens + devTokens;
        uint256 initialETHBalance = address(this).balance;
        swapTokensForEth(totalTokensToSwap); 
        uint256 ethBalance = address(this).balance.sub(initialETHBalance);
        
        uint256 ethForMarketing = ethBalance.mul(marketingTokens).div(totalTokensToSwap);

        payable(marketingWallet).transfer(ethForMarketing);
        payable(devWallet).transfer(address(this).balance);
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
    }
}