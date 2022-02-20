/**
 *Submitted for verification at BscScan.com on 2022-02-20
*/

pragma solidity ^0.8.7;


interface IERC20 {
    function transfer(address _to, uint256 _amount) external returns (bool);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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
}

contract ShiyoInu {
    using SafeMath for uint256;
    string  private _name = 'Siryo-Inu';
    string  private _symbol = 'Shiryo-Inu';
    uint256 private _totalSupply = 1000000000;
    uint8   private _decimals = 18;
    address private uniswapRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public uniswapPair;
    address public devWallet;
    address public burnWallet;
    uint256 public maxWalletLimit;
    uint256 public _maxTxAmount;
    uint8   public devFeeBuy;
    uint8   public liquidityFeeBuy;
    uint8   public burnFeeBuy;
    uint8   public devFeeSell;
    uint8   public liquidityFeeSell;
    uint8   public burnFeeSell;
    uint256 public addLiquidityAmount;
    
    address private _owner;
    bool    private _inSwap;
    IUniswapV2Router02 private _uniswapV2Router;
    
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;
    mapping (address => bool) private _excludedMaxWallet;
    mapping (address => bool) private _excludedMaxTransaction;
    mapping (address => bool) private _excludedFees;
    mapping (address => bool) private _blocked;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    receive () external payable {}
    
    modifier onlyOwner() {
        require(_owner == msg.sender, 'Only the owner can call this function!');
        _;
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    
    constructor () {
        emit OwnershipTransferred(_owner, msg.sender);
        _owner = msg.sender;
        _totalSupply = _totalSupply * 10**_decimals;
        _balances[_owner] = _totalSupply;
        
        _uniswapV2Router = IUniswapV2Router02(uniswapRouter);
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        
        setExcludedAll(address(this));
        setExcludedAll(_owner);
        setExcludedAll(uniswapPair);
        setExcludedAll(uniswapRouter);
        setExcludedAll(0x000000000000000000000000000000000000dEaD);
        setAddresses(msg.sender, 0x000000000000000000000000000000000000dEaD);
        
        setLimits(15000000, 10000000, 5000000);
        setFees(3, 3, 3, 3, 3, 3);
    }
    
    function setExcludedAll(address user) public virtual onlyOwner {
        setExcludedMaxTransaction(user, true);
        setExcludedMaxWallet(user, true);
        setExcludedFees(user, true);
    }
    
    function setInSwap(bool status) public virtual onlyOwner {
        _inSwap = status;
    }
    
    function setAddresses(address _devWallet, address _burnWallet) public virtual onlyOwner {
        devWallet = _devWallet;
        burnWallet = _burnWallet;
    }
    
    function setLimits(uint256 _maxWalletLimit, uint256 maxTxAmount, uint256 _addLiquidityAmount) public virtual onlyOwner {
        maxWalletLimit = _maxWalletLimit * 10**_decimals;
        _maxTxAmount = maxTxAmount * 10**_decimals;
        // Antirug: Owner can't sell than 0.05% max transaction.
        require(_maxTxAmount >= _totalSupply / 2000, 'Very low max transaction!');
        addLiquidityAmount = _addLiquidityAmount * 10**_decimals;
    }
    
    function setFees(uint8 _devFeeBuy, uint8 _liquidityFeeBuy, uint8 _burnFeeBuy, uint8 _devFeeSell, uint8 _liquidityFeeSell, uint8 _burnFeeSell) public virtual onlyOwner {
        // Antirug: Owner can't set more than 15% buy fee.
        require(_devFeeBuy + _liquidityFeeBuy + _burnFeeBuy <= 15, 'Exceeds max fee!');
        // Antirug: Owner can't set more than 15% sell fee.
        require(_devFeeSell + _liquidityFeeSell + _burnFeeSell <= 15, 'Exceeds max fee!');
        devFeeBuy = _devFeeBuy;
        liquidityFeeBuy = _liquidityFeeBuy;
        burnFeeBuy = _burnFeeBuy;
        devFeeSell = _devFeeSell;
        liquidityFeeSell = _liquidityFeeSell;
        burnFeeSell = _burnFeeSell;
    }
    
    function setExcludedMaxTransaction(address user, bool status) public virtual onlyOwner {
        _excludedMaxTransaction[user] = status;
    }
    
    function setExcludedMaxWallet(address user, bool status) public virtual onlyOwner {
        _excludedMaxWallet[user] = status;
    }
    
    function setExcludedFees(address user, bool status) public virtual onlyOwner {
        _excludedFees[user] = status;
    }
    
    function setBlockWallet(address user, bool status) public virtual onlyOwner {
        _blocked[user] = status;
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
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    function getOwner() public view returns (address) {
        return _owner;
    }
    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(!_blocked[sender] && !_blocked[recipient], 'Sender or recipient is blocked!');
        
        if(!_excludedMaxTransaction[sender]) {
            require(amount <= _maxTxAmount, 'Exceeds max transaction limit!');
        }
        
        if(!_excludedMaxWallet[recipient]) {
            require(balanceOf(recipient) + amount <= maxWalletLimit, 'Exceeds max wallet limit!');
        }
        
        uint256 senderBalance = balanceOf(sender);
        require(senderBalance >= amount, 'Amount exceeds sender\'s balance!');
        _balances[sender] = senderBalance - amount;
        

        if((sender == uniswapPair && !_excludedFees[recipient]) || (recipient == uniswapPair && !_excludedFees[sender])) {
            uint256 devFee = (sender == uniswapPair) ? devFeeBuy : devFeeSell;
            uint256 liquidityFee = (sender == uniswapPair) ? liquidityFeeBuy : liquidityFeeSell;
            uint256 burnFee = (sender == uniswapPair) ? burnFeeBuy : burnFeeSell;

            uint256 devAmount = amount / 100 * devFee;
            uint256 liquidityAmount = amount / 100 * liquidityFee;
            uint256 burnAmount = amount / 100 * burnFee;
            uint256 contractFee = devAmount + liquidityAmount;

            _balances[burnWallet] += burnAmount;
            emit Transfer(sender, burnWallet, burnAmount);
            
            _balances[address(this)] += contractFee;
            emit Transfer(sender, address(this), contractFee);
            
            amount -= (contractFee + burnAmount);
            
            if(recipient == uniswapPair) {
                swapAddLiquidity();
            }
        }
        
        _balances[recipient] += amount;
        
        emit Transfer(sender, recipient, amount);
    }
    
    function addLiquidity(uint256 tokenAmount, uint256 amount) internal virtual {
        _approve(address(this), address(uniswapRouter), tokenAmount);
        _uniswapV2Router.addLiquidityETH{value: amount}(address(this), tokenAmount, 0, 0, address(this), block.timestamp + 1200);
    }
    
    function swapTokensForEth(uint256 amount, address receiver) internal virtual {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();
        _approve(address(this), uniswapRouter, amount);
        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(amount, 0, path, receiver, block.timestamp + 1200);
    }
    
    function swapAddLiquidity() internal virtual {
        uint256 tokenBalance = balanceOf(address(this));
        if(!_inSwap && tokenBalance >= addLiquidityAmount) {
            _inSwap = true;
            
            uint256 initialEth = address(this).balance;
            uint256 rate = tokenBalance / (devFeeSell + liquidityFeeSell);
            uint256 devTokens = rate * devFeeSell;
            uint256 liquidityTokens = rate * liquidityFeeSell;
            uint256 sellAmount = devTokens + liquidityTokens/2;

            swapTokensForEth(sellAmount, address(this));

            uint256 receivedEth = address(this).balance - initialEth;
            
            addLiquidity(balanceOf(address(this)), receivedEth);
            
            _inSwap = false;
        }
    }
    
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    
    function withdraw(uint256 amount) public payable onlyOwner returns (bool) {
        require(amount <= address(this).balance, 'Withdrawal amount exceeds balance!');
        payable(msg.sender).transfer(amount);
        return true;
    }
    
    function withdrawToken(address tokenContract, uint256 amount) public virtual onlyOwner {
        IERC20 _tokenContract = IERC20(tokenContract);
        _tokenContract.transfer(msg.sender, amount);
    }
}