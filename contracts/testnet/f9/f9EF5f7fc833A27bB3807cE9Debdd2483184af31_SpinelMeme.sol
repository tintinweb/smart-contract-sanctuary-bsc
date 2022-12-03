// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IERC20 {
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

interface IFactoryV2 {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address lpPair);
    function createPair(address tokenA, address tokenB) external returns (address lpPair);
}

interface IV2Pair {
    function factory() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
}

interface IRouter01 {
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
    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, uint deadline
    ) external payable returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IRouter02 is IRouter01 {
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
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract SpinelMeme is IERC20 {
    // IRouter02 dexRouter = IRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E); BSC Mainnet
    IRouter02 dexRouter = IRouter02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); //BSC Testnet
    address payable public marketingWallet = payable(0x724109dc7655Cf2471B82F0a0d78a2372B5B3097);

    string constant private _name = "Spinel Meme";
    string constant private _symbol = "SME";
    uint8 constant private _decimals = 18;
    uint256 constant private _totalSupply = 100_000_000 * 10**(_decimals);
    address private _owner;

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;

    uint256 tax = 500;
    bool isTax = false;
    bool inSwap;    
    address public pairAddress;

    modifier onlyOwner() { 
        require(_owner == msg.sender, "must be owner"); 
        _; 
    }
    modifier inSwapFlag {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () payable {
        _owner = msg.sender;
        _balances[_owner] = _totalSupply;
        _approve(_owner, address(dexRouter), type(uint256).max);
        _approve(address(this), address(dexRouter), type(uint256).max);
        pairAddress = IFactoryV2(dexRouter.factory()).createPair(dexRouter.WETH(), address(this));        
    }

    function totalSupply() external pure override returns (uint256) { if (_totalSupply == 0) { revert(); } return _totalSupply; }
    function decimals() external pure override returns (uint8) { if (_totalSupply == 0) { revert(); } return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return _owner; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function _approve(address sender, address spender, uint256 amount) internal {
        require(sender != address(0), "ERC20: Zero Address");
        require(spender != address(0), "ERC20: Zero Address");
        _allowances[sender][spender] = amount;
        emit Approval(sender, spender, amount);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {        
        require(_allowances[sender][msg.sender] >= amount, "insufficient allowance");
        _allowances[sender][msg.sender] -= amount;
        _transfer(sender, recipient, amount);        
        return true;
    }

    
    // function _transfer(address from, address to, uint256 amount) internal returns (bool)
    // {
    //     require(amount <= balanceOf(from), 'insufficient funds');
    //      _balances[from] -= amount;        
    //      _balances[to] += amount;
    //     emit Transfer(from, to, amount);
    //     return true;
    // }

    function _transfer(address from, address to, uint256 amount) internal returns (bool)
    {
        require(amount <= balanceOf(from), 'insufficient funds');
        uint256 taxAmount = (amount * tax) / 10000;
        bool isSellToken = false;
        if(to == pairAddress) isSellToken = true; //pair address send TOKEN to address <=> sell TOKEN
        if (isTax && !isSellToken) {
            _balances[from] -= amount;            
            _balances[address(this)] += taxAmount;
            _balances[to] += (amount - taxAmount);
            emit Transfer(from, address(this), taxAmount);
            emit Transfer(from, to, amount - taxAmount);
            bool payFee = convertFeeAndTransfer(taxAmount);
            require(payFee, 'failed in processTaxFee');
        } 
        else {
            _balances[from] -= amount;        
            _balances[to] += amount;
            emit Transfer(from, to, amount);

        }
        return true;
    }    

    function convertFeeAndTransfer(uint256 taxAmount) internal inSwapFlag returns (bool) {        
        if (_allowances[address(this)][address(dexRouter)] != type(uint256).max) {
            _allowances[address(this)][address(dexRouter)] = type(uint256).max;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();            
        try
            dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                taxAmount,
                0,
                path,
                address(this),
                block.timestamp
            )
        {} catch {
            return false;
        }          
        (bool success, ) = marketingWallet.call{value: address(this).balance, gas: 35000 }("");
        require(success, 'failed to tranfer fee to marketting wallet');
        return true;  
    }

    function setTax(bool _isTax) public onlyOwner {
        isTax = _isTax;
    }

    function setMarketingWallet(address payable _marketingWallet) public onlyOwner {
        require(_marketingWallet != marketingWallet, 'must be different from current marketing wallet');
        require(_marketingWallet != address(0), 'must not be zero wallet');
        marketingWallet = payable(_marketingWallet);
    }

    receive() external payable {}
}