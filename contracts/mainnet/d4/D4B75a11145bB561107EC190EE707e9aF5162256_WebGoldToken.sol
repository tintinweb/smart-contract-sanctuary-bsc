/**
 *Submitted for verification at BscScan.com on 2022-11-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);
        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }

    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

library SafeMathUint {
    function toInt256Safe(uint256 a) internal pure returns (int256) {
        int256 b = int256(a);
        require(b >= 0);
        return b;
    }
}

library IterableMapping {
    
    struct Map {
        address[] keys;
        mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) internal view returns (uint256) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key) internal view returns (int256) {
        if (!map.inserted[key]) {
            return -1;
        }
        return int256(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint256 index) internal view returns (address) {
        return map.keys[index];
    }

    function size(Map storage map) internal view returns (uint256) {
        return map.keys.length;
    }

    function set( Map storage map, address key, uint256 val ) internal {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) internal {
        if (!map.inserted[key]) {
            return;
        }
        delete map.inserted[key];
        delete map.values[key];
        uint256 index = map.indexOf[key];
        uint256 lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];
        map.indexOf[lastKey] = index;
        delete map.indexOf[key];
        map.keys[index] = lastKey;
        map.keys.pop();
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

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

    function sub(uint256 a, uint256 b, string memory errorMessage ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod( uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

library Clones {

    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(address implementation, bytes32 salt, address deployer) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    function predictDeterministicAddress(address implementation, bytes32 salt) internal view returns (address predicted) {
        return predictDeterministicAddress(implementation, salt, address(this));
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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

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
    event Swap(address indexed sender, uint amount0In, uint amount1In, uint amount0Out, uint amount1Out, address indexed to);
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

interface IUniswapV2Factory {

    event PairCreated( address indexed token0, address indexed token1, address pair, uint256 );

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Router01 {

    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(address tokenA, address tokenB, uint256 amountADesired, uint256 amountBDesired, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline ) 
        external returns (uint256 amountA, uint256 amountB, uint256 liquidity );

    function addLiquidityETH( address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin,  address to, uint256 deadline ) 
        external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountOut);
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountIn);
    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

abstract contract Initializable {
    bool private _initialized;
    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");
        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

interface IERC20Upgradeable {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20MetadataUpgradeable is IERC20Upgradeable {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {}

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {
        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {
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

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        _afterTokenTransfer(sender, recipient, amount);
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

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    uint256[45] private __gap;
}

interface DividendPayingTokenInterface {
    function dividendOf(address _owner) external view returns (uint256);
    function withdrawDividend() external;
    event DividendsDistributed(address indexed from, uint256 weiAmount);
    event DividendWithdrawn(address indexed to, uint256 weiAmount);
}

interface DividendPayingTokenOptionalInterface {
    function withdrawableDividendOf(address _owner) external view returns (uint256);
    function withdrawnDividendOf(address _owner) external view returns (uint256);
    function accumulativeDividendOf(address _owner) external view returns (uint256);
}

contract DividendPayingToken is ERC20Upgradeable, OwnableUpgradeable, DividendPayingTokenInterface, DividendPayingTokenOptionalInterface {

    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;

    address public rewardToken;
    uint256 internal constant magnitude = 2**128;
    uint256 internal magnifiedDividendPerShare;
    mapping(address => int256) internal magnifiedDividendCorrections;
    mapping(address => uint256) internal withdrawnDividends;

    uint256 public totalDividendsDistributed;

    function __DividendPayingToken_init( address _rewardToken, string memory _name, string memory _symbol ) internal initializer {
        __Ownable_init();
        __ERC20_init(_name, _symbol);
        rewardToken = _rewardToken;
    }

    function distributeCAKEDividends(uint256 amount) public onlyOwner {
        require(totalSupply() > 0);
        if (amount > 0) {
            magnifiedDividendPerShare = magnifiedDividendPerShare.add((amount).mul(magnitude) / totalSupply());
            emit DividendsDistributed(msg.sender, amount);
            totalDividendsDistributed = totalDividendsDistributed.add(amount);
        }
    }

    function withdrawDividend() public virtual override {
        _withdrawDividendOfUser(payable(msg.sender));
    }

    function _withdrawDividendOfUser(address payable user) internal returns (uint256) {
        uint256 _withdrawableDividend = withdrawableDividendOf(user);
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user] = withdrawnDividends[user].add(_withdrawableDividend); 
            emit DividendWithdrawn(user, _withdrawableDividend);
            bool success = IERC20(rewardToken).transfer(user, _withdrawableDividend);
            if (!success) {
                withdrawnDividends[user] = withdrawnDividends[user].sub(_withdrawableDividend);
                return 0;
            }
            return _withdrawableDividend;
        }
        return 0;
    }

    function dividendOf(address _owner) public view override returns (uint256) {
        return withdrawableDividendOf(_owner);
    }

    function withdrawableDividendOf(address _owner) public view override returns (uint256) {
        return accumulativeDividendOf(_owner).sub(withdrawnDividends[_owner]);
    }

    function withdrawnDividendOf(address _owner) public view override returns (uint256) {
        return withdrawnDividends[_owner];
    }

    function accumulativeDividendOf(address _owner) public view override returns (uint256) {
        return magnifiedDividendPerShare.mul(balanceOf(_owner)).toInt256Safe().add(magnifiedDividendCorrections[_owner]).toUint256Safe() / magnitude;
    }

    function _transfer( address from, address to, uint256 value ) internal virtual override {
        require(false);
        int256 _magCorrection = magnifiedDividendPerShare.mul(value).toInt256Safe();
        magnifiedDividendCorrections[from] = magnifiedDividendCorrections[from].add(_magCorrection);
        magnifiedDividendCorrections[to] = magnifiedDividendCorrections[to].sub(_magCorrection);
    }

    function _mint(address account, uint256 value) internal override {
        super._mint(account, value);
        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account].sub((magnifiedDividendPerShare.mul(value)).toInt256Safe());
    }

    function _burn(address account, uint256 value) internal override {
        super._burn(account, value);
        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account].add((magnifiedDividendPerShare.mul(value)).toInt256Safe());
    }

    function _setBalance(address account, uint256 newBalance) internal {
        uint256 currentBalance = balanceOf(account);
        if (newBalance > currentBalance) {
            uint256 mintAmount = newBalance.sub(currentBalance);
            _mint(account, mintAmount);
        } else if (newBalance < currentBalance) {
            uint256 burnAmount = currentBalance.sub(newBalance);
            _burn(account, burnAmount);
        }
    }
}

contract WebGoldTokenDividendTracker is OwnableUpgradeable, DividendPayingToken {

    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping(address => bool) public excludedFromDividends;
    mapping(address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event Claim( address indexed account, uint256 amount, bool indexed automatic);

    function initialize( address rewardToken_, uint256 minimumTokenBalanceForDividends_, uint256 claimWait_ ) external initializer {
        DividendPayingToken.__DividendPayingToken_init(rewardToken_, "WEBGOLD_DIVIDEND_TRACKER", "WEBGOLD_DIVIDEND_TRACKER");
        claimWait = claimWait_;
        minimumTokenBalanceForDividends = minimumTokenBalanceForDividends_;
    }

    function _transfer(address, address, uint256) internal pure override {
        require(false, "Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() public pure override {
        require( false, "Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main BABYTOKEN contract." );
    }

    function excludeFromDividends(address account) external onlyOwner {
        require(!excludedFromDividends[account]);
        excludedFromDividends[account] = true;
        _setBalance(account, 0);
        tokenHoldersMap.remove(account);
        emit ExcludeFromDividends(account);
    }

    function isExcludedFromDividends(address account) public view returns(bool) {
        return excludedFromDividends[account];
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require( newClaimWait != claimWait, "Dividend_Tracker: Cannot update claimWait to same value" );
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function updateMinimumTokenBalanceForDividends(uint256 amount) external onlyOwner {
        minimumTokenBalanceForDividends = amount;
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns (uint256) {
        return tokenHoldersMap.keys.length;
    }

    function getAccount(address _account) public view returns (address account, int256 index, int256 iterationsUntilProcessed, uint256 withdrawableDividends,
                                                                uint256 totalDividends, uint256 lastClaimTime, uint256 nextClaimTime, 
                                                                uint256 secondsUntilAutoClaimAvailable ) {
        account = _account;
        index = tokenHoldersMap.getIndexOfKey(account);
        iterationsUntilProcessed = -1;

        if ( index >= 0 ) {
            if (uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
            } else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex ? tokenHoldersMap.keys.length.sub(lastProcessedIndex) : 0;
                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }

        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);
        lastClaimTime = lastClaimTimes[account];
        nextClaimTime = lastClaimTime > 0 ? lastClaimTime.add(claimWait) : 0;
        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ? nextClaimTime.sub(block.timestamp) : 0;
    }

    function getAccountAtIndex(uint256 index) public view returns ( address, int256, int256, uint256, uint256, uint256, uint256, uint256 ) {
        if ( index >= tokenHoldersMap.size() ) {
            return (address(0), -1, -1, 0, 0, 0, 0, 0);
        }
        address account = tokenHoldersMap.getKeyAtIndex(index);
        return getAccount(account);
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
        if ( lastClaimTime > block.timestamp ) {
            return false;
        }
        return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(address payable account, uint256 newBalance) external onlyOwner {
        if ( excludedFromDividends[account] ) {
            return;
        }
        if ( newBalance >= minimumTokenBalanceForDividends ) {
            _setBalance(account, newBalance);
            tokenHoldersMap.set(account, newBalance);
        } else {
            _setBalance(account, 0);
            tokenHoldersMap.remove(account);
        }
        processAccount(account, true);
    }
    
    function process(uint256 gas) public returns ( uint256, uint256, uint256 ) {
        
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;
        if ( numberOfTokenHolders == 0 ) {
            return (0, 0, lastProcessedIndex);
        }

        uint256 _lastProcessedIndex = lastProcessedIndex;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        uint256 claims = 0;

        while ( gasUsed < gas && iterations < numberOfTokenHolders ) {
            _lastProcessedIndex++;
            if (_lastProcessedIndex >= tokenHoldersMap.keys.length) {
                _lastProcessedIndex = 0;
            }
            address account = tokenHoldersMap.keys[_lastProcessedIndex];
            if ( canAutoClaim(lastClaimTimes[account]) ) {
                if ( processAccount(payable(account), true) ) {
                    claims++;
                }
            }
            iterations++;
            uint256 newGasLeft = gasleft();
            if ( gasLeft > newGasLeft ) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }
            gasLeft = newGasLeft;
        }

        lastProcessedIndex = _lastProcessedIndex;
        return (iterations, claims, lastProcessedIndex);
    }

    function processAccount(address payable account, bool automatic) public onlyOwner returns (bool) {
        uint256 amount = _withdrawDividendOfUser(account);
        if ( amount > 0 ) {
            lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
            return true;
        }
        return false;
    }
}

contract WebGoldToken is IERC20Metadata, Ownable {

    using SafeMath for uint256;
    using IterableMapping for IterableMapping.Map;

    event ProcessedDividendTracker(uint256 iterations, uint256 claims, uint256 lastProcessedIndex, 
                bool indexed automatic, uint256 gas, address indexed processor);

    uint256 constant MAX_UINT = ~uint256(0);
    uint256 constant TOKEN_UNIT = 10**18;
    uint256 constant MAX_SUPPLY = 10**8 * TOKEN_UNIT;

    uint256 constant FEE_DENOMINATOR = 10000;
    uint256 constant SWAP_LPDIVIDEND_FEE = 300;
    uint256 constant SWAP_MARKETING_FEE = 200;
    uint256 constant SWAP_TOTAL_FEES = 500;
    uint256 constant TRANSFER_BURN_FEE = 1;

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    string private _name = "WebGold";
    string private _symbol = "BGD";   
    uint8 private _decimals = 18;
    uint256 private _totalSupply;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    IERC20 public usdtToken;
    mapping(address => bool) public ammPairs;
    address public initPoolAddr;

    mapping(address => uint256) private _swaplist;
    IterableMapping.Map private _botlist;
    uint256 public minSwapSecs = 15 seconds;
    uint256 public blockedSecs = 3 minutes;

    WebGoldTokenDividendTracker public dividendTracker;
    uint256 public gasForProcessing;
    address public mktAddr;
    
    address private _fromAddr;
    address private _toAddr;

    mapping(address => bool) private _isExcludedFromFees;

    constructor(address[5] memory configAddrs, address[4] memory distributions_) {

        mktAddr = configAddrs[2];
        initPoolAddr = configAddrs[3];
        gasForProcessing = 300000;

        dividendTracker = WebGoldTokenDividendTracker( payable(Clones.clone(configAddrs[4])) );
        dividendTracker.initialize( address(this), 10**17, 43200 );

        usdtToken = IERC20(configAddrs[0]); 
        IUniswapV2Router02 uniswapV2Router_ = IUniswapV2Router02(configAddrs[1]);

        address uniswapV2Pair_ = IUniswapV2Factory(uniswapV2Router_.factory()).createPair(address(this), address(usdtToken));
        uniswapV2Router = uniswapV2Router_;
        uniswapV2Pair = uniswapV2Pair_;
        ammPairs[uniswapV2Pair_] = true;

        excludeFromFees(address(dividendTracker), true);
        excludeFromFees(initPoolAddr, true);
        excludeFromFees(address(this), true);
        excludeFromFees(owner(), true);

        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(address(0));
        dividendTracker.excludeFromDividends(address(0xdead));
        dividendTracker.excludeFromDividends(uniswapV2Pair_);
        dividendTracker.excludeFromDividends(initPoolAddr);

        _mint( distributions_[0], MAX_SUPPLY.mul(70).div(100) );
        _mint( distributions_[1], MAX_SUPPLY.mul(10).div(100) );
        _mint( distributions_[2], MAX_SUPPLY.mul(5).div(100) );
        _mint( distributions_[3], MAX_SUPPLY.mul(15).div(100) );
    }

    receive() external payable {}

    function isExcludedFromFees(address acc_) public view returns (bool) {
        return _isExcludedFromFees[acc_];
    }

    function excludeFromFees(address acc_, bool excluded_) public onlyOwner {
        if ( _isExcludedFromFees[acc_] != excluded_ ) {
            _isExcludedFromFees[acc_] = excluded_;
        }
    }

    function excludeMultipleAccountsFromFees( address[] calldata accounts_, bool excluded_ ) public onlyOwner {
        for (uint256 i = 0; i < accounts_.length; i++) {
            _isExcludedFromFees[accounts_[i]] = excluded_;
        }
    }

    function setAmmPair(address pair_, bool hasPair_) external onlyOwner{
        ammPairs[pair_] = hasPair_;
    }

    function setMarketingWallet(address wallet_) external onlyOwner {
        mktAddr = wallet_;
    }

    function getBot(address acc_) public view returns (uint256) {
        return _botlist.get(acc_);
    }

    function getNumberOfBots() public view returns (uint256) {
        return _botlist.size();
    }

    function resetBot(address acc_, uint256 lockTs_) public onlyOwner {
        _botlist.set(acc_, lockTs_);
    }

    function setMinTsForSwap(uint newSecs_) public onlyOwner {
        minSwapSecs = newSecs_;
    }

    function setBlockedTs(uint newSecs_) public onlyOwner {
        blockedSecs = newSecs_;
    }

    function updateGasForProcessing(uint256 newValue_) public onlyOwner {
        require( newValue_ != gasForProcessing, "WGUGFP01" );
        gasForProcessing = newValue_;
    }

    function updateClaimWait(uint256 claimWait_) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait_);
    }

    function getClaimWait() external view returns (uint256) {
        return dividendTracker.claimWait();
    }

    function updateMinimumTokenBalanceForDividends(uint256 amount_) external onlyOwner {
        dividendTracker.updateMinimumTokenBalanceForDividends(amount_);
    }

    function getMinimumTokenBalanceForDividends() external view returns (uint256) {
        return dividendTracker.minimumTokenBalanceForDividends();
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function withdrawableDividendOf(address acc_) external view returns (uint256) {
        return dividendTracker.withdrawableDividendOf(acc_);
    }

    function dividendTokenBalanceOf(address acc_) external view returns (uint256) {
        return dividendTracker.balanceOf(acc_);
    }

    function excludeFromDividends(address acc_) external onlyOwner {
        dividendTracker.excludeFromDividends(acc_);
    }

    function isExcludedFromDividends(address acc_) external view returns (bool) {
        return dividendTracker.isExcludedFromDividends(acc_);
    }

    function getAccountDividendsInfo(address acc_) external view returns (address, int256, int256, uint256, uint256, uint256, uint256, uint256) {
        return dividendTracker.getAccount(acc_);
    }

    function getAccountDividendsInfoAtIndex(uint256 index_) external view returns (address,int256,int256,uint256,uint256,uint256,uint256,uint256) {
        return dividendTracker.getAccountAtIndex(index_);
    }

    function processDividendTracker( uint256 gas_ ) external {
        ( uint256 iterations_, uint256 claims_, uint256 lastProcessedIndex_ ) = dividendTracker.process( gas_ );
        emit ProcessedDividendTracker( iterations_, claims_, lastProcessedIndex_, false, gas_, tx.origin );
    }

    function claim() external {
        dividendTracker.processAccount(payable(msg.sender), false);
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns (uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function _transfer( address from_, address to_, uint256 amount_ ) private {

        require( from_ != address(0), "WGT01" );
        require( to_ != address(0), "WGT02" );
        require(amount_ > 0, "WGT03");

        bool bSwap_;
        bool bFeesOnSell_;

        if ( _botlist.get(from_) != 0 && blockedSecs != 0) {
            require(block.timestamp > _botlist.get(from_), "WGT04");
            _botlist.set(from_, 0);
        }

        if ( ammPairs[from_] ) {
            _swaplist[to_] = block.timestamp;
            bSwap_ = true;
        }
        else {
            if ( ammPairs[to_] ) {
                bFeesOnSell_ = true;
                bSwap_ = true;
                if ( _swaplist[from_] != 0 ) {
                    if (block.timestamp == _swaplist[from_] && blockedSecs != 0) {
                        _botlist.set(from_, block.timestamp + blockedSecs); // is bot!
                        revert("WGT05");
                    }
                    require((block.timestamp - _swaplist[from_]) > minSwapSecs, "WGT06");
                    _swaplist[from_] = 0;
                }
                if ( IERC20(to_).totalSupply() == 0 ) {
                    require(from_ == initPoolAddr, "WGT07");
                }
            }
        }

        uint256 netAmount_ = amount_;
        if ( !_isExcludedFromFees[from_] && !_isExcludedFromFees[to_] ) {
            if ( bFeesOnSell_ ) {
                uint256 fees_ = amount_.mul(SWAP_TOTAL_FEES).div(FEE_DENOMINATOR);
                uint256 dividends_ = fees_.mul(SWAP_LPDIVIDEND_FEE).div(SWAP_TOTAL_FEES);
                netAmount_ = amount_.sub(fees_);
                _take( from_, mktAddr, fees_.mul(SWAP_MARKETING_FEE).div(SWAP_TOTAL_FEES) );
                _take( from_, address(dividendTracker), dividends_ );
                if ( dividendTracker.getNumberOfTokenHolders() > 0 ) {
                    dividendTracker.distributeCAKEDividends(dividends_);
                }
            }
            if (!bSwap_) {
                uint256 fees_ = amount_.mul(TRANSFER_BURN_FEE).div(FEE_DENOMINATOR);
                netAmount_ = amount_.sub(fees_);
                _take( from_, address(0), fees_ );
            }
        }

        _tokenTransfer( from_, to_, amount_, netAmount_ );
        _handleDividends(bSwap_, from_, to_);
    }

    function _take(address from_, address to_, uint256 tValue_) private {
        _tOwned[to_] = _tOwned[to_].add(tValue_);
        emit Transfer(from_, to_, tValue_);
    }

    function _tokenTransfer(address from_, address to_, uint256 amount_, uint256 netAmount_) private {
        _tOwned[from_] = _tOwned[from_].sub(amount_, "WGTT01");
        _tOwned[to_] = _tOwned[to_].add(netAmount_);
        emit Transfer(from_, to_, netAmount_);
    }

    function _handleDividends(bool bSwap_, address from_, address to_) private {
        _setLP(_fromAddr);
        _setLP(_toAddr);
        if (bSwap_) {
            _fromAddr = from_;
            _toAddr = to_;
        }
        else {
            uint256 gas_ = gasForProcessing;
            try dividendTracker.process(gas_) returns ( uint256 iterations_, uint256 claims_, uint256 lastProcessedIndex_ ) {
                emit ProcessedDividendTracker( iterations_, claims_, lastProcessedIndex_, true, gas_, tx.origin );
            } catch {}
        }
    }

    function _setLP(address user_) private {
        if ( user_ != address(0) && !dividendTracker.isExcludedFromDividends(user_) ) { 
            try dividendTracker.setBalance( payable(user_), IUniswapV2Pair(uniswapV2Pair).balanceOf(user_) ) {} catch {}
        }
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address acc_) external view override returns (uint256) {
        return _tOwned[acc_];
    }

    function transfer(address to_, uint256 amount_) external override returns (bool) {
        _transfer(_msgSender(), to_, amount_);
        return true;
    }

    function allowance(address owner_, address spender_) external view override returns (uint256) {
        return _allowances[owner_][spender_];
    }

    function approve(address spender_, uint256 amount_) external override returns (bool) {
        _approve(_msgSender(), spender_, amount_);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount_) external override returns (bool) {
        _transfer(sender, recipient, amount_);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount_, "WGTF01"));
        return true;
    }

    function increaseAllowance(address spender_, uint256 addedValue_) external returns (bool) {
        _approve(_msgSender(), spender_, _allowances[_msgSender()][spender_].add(addedValue_));
        return true;
    }

    function decreaseAllowance(address spender_, uint256 subtractedValue_) external returns (bool) {
        _approve(_msgSender(), spender_, _allowances[_msgSender()][spender_].sub(subtractedValue_, "WGDA01"));
        return true;
    }

    function burn(uint amount_) external {
        _burn(_msgSender(), amount_);
    }

    function burnFrom(address from_, uint amount_) external {
        _approve(from_, _msgSender(), _allowances[from_][_msgSender()].sub(amount_, "WGBF01"));
        _burn(from_, amount_);
    }

    function _approve(address owner_, address spender_, uint256 amount_) private {
        require(owner_ != address(0), "WGA01");
        require(spender_ != address(0), "WGA02");
        _allowances[owner_][spender_] = amount_;
        emit Approval(owner_, spender_, amount_);
    }

   function _mint(address to_, uint amount_) private {
        _totalSupply = _totalSupply.add(amount_);
        _tOwned[to_] = _tOwned[to_].add(amount_);
        emit Transfer(address(0), to_, amount_);
    }

    function _burn(address from_, uint amount_) private {
        _tOwned[from_] = _tOwned[from_].sub(amount_);
        _totalSupply = _totalSupply.sub(amount_);
        emit Transfer(from_, address(0), amount_);
    }
}