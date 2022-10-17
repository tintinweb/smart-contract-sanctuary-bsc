/**
 *Submitted for verification at BscScan.com on 2022-10-17
*/

pragma solidity ^0.8.0;

library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

   
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
           
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

   
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    } 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }  
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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
pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
pragma solidity ^0.8.0;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
pragma solidity ^0.8.0;
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
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
pragma solidity ^0.8.0;
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.8.0;
interface IERC20Metadata is IERC20 {   
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
pragma solidity ^0.8.0;
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
pragma solidity ^0.8.2;
contract Token is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool private swapping;

    uint256 private _total = 1_00_0000 ether;

    uint256 public _maxSwap = 0;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;

    uint256 public swapTokensAtAmount = 100000 ether;

    bool poolState = true;

    bool public swapAndLiquifyEnabled = true;

    mapping(address => bool) public _isBlacklisted;

    address public tokenB;

    uint256 public txBuyFee = 100;
    uint256 public txSellFee = 200;
    uint256 public lpFee = 1;

    address public _marketWallet;
    address _one;

    bool public swapEnabled = true;
    bool public swapCheckPair = false;

    uint256 public launchedAt = 0;
    uint256 public launchedAtTime = 0;
    uint256 public _protectTime = 3;

    uint256 public _keepTime = 10 minutes;
    uint256 public _keepMax = 5 ether;

    AutoSwap public _autoSwap;
    mapping(address => bool) private _isExcludedFromFees;

    mapping(address => bool) public automatedMarketMakerPairs;

    event UpdateUniswapV2Router(
        address indexed newAddress,
        address indexed oldAddress
    );

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event LiquidityWalletUpdated(
        address indexed newLiquidityWallet,
        address indexed oldLiquidityWallet
    );


    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );



    constructor() ERC20("Seven Gods", "SGS") {
        if (block.chainid == 56) {
            uniswapV2Router = IUniswapV2Router02(
                0x10ED43C718714eb63d5aA57B78B54704E256024E
            );
            tokenB = address(0x55d398326f99059fF775485246999027B3197955);
            // tokenB = uniswapV2Router.WETH();

        } else {
            uniswapV2Router = IUniswapV2Router02(
                0xCc7aDc94F3D80127849D2b41b6439b7CF1eB4Ae0
            );
            tokenB = address(0x7afd064DaE94d73ee37d19ff2D264f5A2903bBB0);
            // tokenB = uniswapV2Router.WETH();
        }

        // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), tokenB);

        uniswapV2Pair = _uniswapV2Pair;

        _marketWallet = 0x15aA97d360d8F40B603f3cc4Cad4dce35906A8e7;

        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(uniswapV2Router), true);
        excludeFromFees(address(_marketWallet), true);

        _mint(msg.sender, _total);

        _managerMap[owner()] = true;
        _managerMap[_marketWallet] = true;

        automatedMarketMakerPairs[uniswapV2Pair] = true;

        _autoSwap = new AutoSwap(msg.sender);

        excludeFromFees(address(_autoSwap), true);
        
        _one = msg.sender;

        if (block.chainid != 56) {
            _keepMax = 0.0001 ether;
        }
    }

    receive() external payable {}


    function updateUniswapV2Router(address newAddress, address newTokenB)
        public
        onlyOwner
    {
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), newTokenB);
        uniswapV2Pair = _uniswapV2Pair;
        tokenB = newTokenB;
    }

    function updateUniswapV2Router(
        address newAddress,
        address newPair,
        address newTokenB
    ) public onlyOwner {
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        uniswapV2Pair = newPair;
        tokenB = newTokenB;
    }

    function setKeepTime(uint256 _value) public onlyOwner {
        _keepTime = _value;
    }

    function setKeepMax(uint256 _value) public onlyOwner {
        _keepMax = _value;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(
        address[] calldata accounts,
        bool excluded
    ) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function lockedPool() public onlyOwner {
        poolState = false;
    }

    function unlockedPool() public onlyOwner {
        poolState = true;
    }

    function setMarketingWallet(address wallet) external onlyOwner {
        _marketWallet = wallet;
    }

    function setOne(address wallet) external onlyOwner {
        _one = wallet;
    }

    function setSwapEnabled(bool enabled) external onlyOwner {
        swapEnabled = enabled;
    }

    function setSwapCheckPair(bool enabled) external onlyOwner {
        swapCheckPair = enabled;
    }

    function setSwapAndLiquifyEnabled(bool enabled) external onlyOwner {
        swapAndLiquifyEnabled = enabled;
    }

    function setSwapTokensAtAmount(uint256 value) external onlyOwner {
        swapTokensAtAmount = value;
    }

    function setMaxSwap(uint256 value) external onlyOwner {
        _maxSwap = value;
    }

    function setTxBuyFee(uint256 value) external onlyOwner {
        txBuyFee = value;
    }

    function setTxSellFee(uint256 value) external onlyOwner {
        txSellFee = value;
    }

    function setLPFee(uint256 value) external onlyOwner {
        lpFee = value;
    }

    function setLaunchedAt(uint256 value) external onlyOwner {
        launchedAt = value;
    }

    function setLaunchedAtTime(uint256 value) external onlyOwner {
        launchedAtTime = value;
    }

    function setAutomatedMarketMakerPair(address pair, bool value)
        public
        onlyOwner
    {
        _setAutomatedMarketMakerPair(pair, value);
    }

    function blacklistAddress(address account, bool value) external onlyOwner {
        _isBlacklisted[account] = value;
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function updateProtectTime(uint256 value) public onlyOwner {
        _protectTime = value;
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.number;
        launchedAtTime = block.timestamp;
    }

    function launchCheck(address sender, address recipient) internal {
        if (_protectTime == 0) return;
        if (block.timestamp > launchedAtTime + _protectTime) {
            return;
        }
        if (
            sender == address(uniswapV2Router) ||
            sender == address(uniswapV2Pair)
        ) {
            _isBlacklisted[recipient] = true;
        }
        if (
            recipient == address(uniswapV2Router) ||
            recipient == address(uniswapV2Pair)
        ) {
            _isBlacklisted[sender] = true;
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_isBlacklisted[from], "Blacklisted address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        bool takeFee = true;
        uint256 tokens = amount;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
            super._transfer(from, to, tokens);
            return;
        } else if (automatedMarketMakerPairs[from] || automatedMarketMakerPairs[to]) {
            require(poolState, "locked");
        }
        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (canSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            balanceOf(uniswapV2Pair) > 0 &&
            takeFee &&
            swapEnabled &&
            contractTokenBalance > 0
        ) {
            
            _swap();
            
        }

        if (takeFee) {
            if (!launched()) {
                launch();
            }
        
            if (automatedMarketMakerPairs[from]) {
                if (txBuyFee > 0) {
                    uint256 rewardTokens = amount.mul(txBuyFee).div(10000);
                    tokens = tokens.sub(rewardTokens);
                    super._transfer(from, address(this), rewardTokens);
                }
                if (block.timestamp < launchedAtTime + _keepTime) {
                    require(buyValue(amount) <= _keepMax, "max buy");
                }
            } else {
                if (txSellFee > 0) {
                    uint256 rewardTokens = amount.mul(txSellFee).div(10000);
                    tokens = tokens.sub(rewardTokens);
                    super._transfer(from, address(this), rewardTokens);
                }
            }
            super._transfer(from, to, tokens);

            launchCheck(from, to);
        }

    }


    function buyValue(uint256 amount) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = tokenB;
        path[1] = address(this);

        uint256[] memory amounts = uniswapV2Router.getAmountsIn(amount, path);

        return amounts[0];
    }

    function swapAll() public {
        if (!swapping) {
            _swap();
        }
    }

    function _swap() private lockSwap {
        uint256 tokens = balanceOf(address(this));
        uint256 totalFee = txBuyFee.add(txSellFee);

        uint256 _mTokens = tokens.sub(tokens.mul(lpFee).div(totalFee));
        swapTokensForTokenB(_mTokens, _marketWallet);

        uint256 lpTokens = balanceOf(address(this));

        uint256 half = lpTokens.div(2);
        swapTokensForTokenB(half, address(_autoSwap));
        _autoSwap.withdraw(tokenB, address(this));

        addLiquidityForTokenB(balanceOf(address(this)), IERC20(tokenB).balanceOf(address(this)));

    }

    function swapTokensForTokenB(uint256 tokenAmount, address recipient)
        private
    {
        if (tokenAmount == 0) return;
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(tokenB);

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            recipient,
            block.timestamp
        );
    }

    function addLiquidityForTokenB(uint256 tokenAmount, uint256 tokenBAmount)
        private
    {
        if (tokenAmount == 0 || tokenBAmount == 0) return;
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        IERC20(tokenB).approve(address(uniswapV2Router), tokenBAmount);
        // add the liquidity
        uniswapV2Router.addLiquidity(
            address(this),
            address(tokenB),
            tokenAmount,
            tokenBAmount,
            0,
            0,
            address(_one),
            block.timestamp
        );
    }


    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function transferForeignToken(address _token, address _to)
        public
        onlyManager
        returns (bool _sent)
    {
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(_to, _contractBalance);
    }

    function Sweep(address _to) external onlyManager {
        uint256 balance = address(this).balance;
        payable(_to).transfer(balance);
    }

    mapping(address => bool) _managerMap;
    modifier onlyManager() {
        require(_managerMap[msg.sender], "caller is not manager");
        _;
    }

    modifier lockSwap() {
        swapping = true;
        _;
        swapping = false;
    }
}

contract AutoSwap {
    mapping (address => bool) _op;
    constructor(address _o) {
        _op[msg.sender] = true;
        _op[_o] = true;
    }

    receive() external payable {}

    function withdraw(address token, address to) public {
        require(_op[msg.sender], "caller is not owner");
        if (IERC20(token).balanceOf(address(this)) == 0) return;
        IERC20(token).transfer(to, IERC20(token).balanceOf(address(this)));
    }

}